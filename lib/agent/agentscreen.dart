import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:finalsalesrep/l10n/app_localization_en.dart'
    show AppLocalizationsEn;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// Placeholder imports (ensure these exist in your project)
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/agencymodel.dart';
import 'package:finalsalesrep/modelclasses/selfietimeresponse.dart'
    show SelfieTimesResponse, SelfieSession;
import 'package:finalsalesrep/offline/attendance/localdbattendance.dart';
import 'package:finalsalesrep/offline/attendance/offlineattendance.dart';
import 'package:finalsalesrep/offline/savedformscreen.dart';
import 'package:finalsalesrep/modelclasses/routemap.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/agent/addextrapoint.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/agent/coustmerform.dart';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/agent/onedayhistory.dart';

// Placeholder for LocalDbAgency
class LocalDbAgency {
  static final LocalDbAgency instance = LocalDbAgency._();
  LocalDbAgency._();

  Future<void> insertPendingAssignment(int userId, int pinLocationId,
      {Map<String, dynamic>? extraData}) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingAssignments = prefs.getString('pending_assignments') ?? '[]';
    final assignments = jsonDecode(pendingAssignments) as List<dynamic>;
    assignments.add({
      'userId': userId,
      'pinLocationId': pinLocationId,
      'extraData': extraData,
    });
    await prefs.setString('pending_assignments', jsonEncode(assignments));
  }

  Future<List<Map<String, dynamic>>> getPendingAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingAssignments = prefs.getString('pending_assignments') ?? '[]';
    return (jsonDecode(pendingAssignments) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<void> clearPendingAssignment(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingAssignments = prefs.getString('pending_assignments') ?? '[]';
    final assignments = jsonDecode(pendingAssignments) as List<dynamic>;
    if (index >= 0 && index < assignments.length) {
      assignments.removeAt(index);
      await prefs.setString('pending_assignments', jsonEncode(assignments));
    }
  }
}

class Agentscreen extends StatefulWidget {
  const Agentscreen({super.key});

  @override
  State<Agentscreen> createState() => _AgentscreenState();
}

class _AgentscreenState extends State<Agentscreen> {
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _syncingActions = false;

  final TextEditingController dateController = TextEditingController();
  String agentname = "";
  List<Record> records = [];
  bool _isLoading = true;
  bool isWorking = false;
  Timer? _sessionCheckTimer;
  RouteMap? fullRouteMap;
  final ImagePicker _picker = ImagePicker();
  String? _startWorkPhotoBase64;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;
  List<SelfieSession> _selfieSessions = [];
  final Onedayagent _onedayagent = Onedayagent();
  bool _isSyncing = false;

  // Agency dropdown related variables
  List<AgencyData> _agencyList = [];
  String? _selectedAgencyId;
  bool _isLoadingAgencies = false;
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _selectedAgencyController =
      TextEditingController();
  AgencyData? _selectedAgency;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('EEE, MMM d, y').format(DateTime.now());
    _initializeData();
    _setupConnectivityListener();
    startTokenValidation();
  }

  void _setupConnectivityListener() {
    _connSub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      final isOnline = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
      if (isOnline && mounted) {
        try {
          await _trySyncPendingActions();
          await syncPendingForms();
          await syncPendingAssignments();
          await fetchAgencies(); // Sync agencies when online
        } catch (e) {
          debugPrint("Error syncing data on connectivity change: $e");
          _showErrorSnackBar("Failed to sync data: $e");
        }
      }
    });
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final isOnline = await _isOnline();
      await Future.wait([
        loadAgentData(),
        loadWorkStatus(),
        isOnline ? fetchAgencies() : _loadCachedAgenciesOrDefault(),
        if (isOnline) fetchSelfieTimes(),
        if (isOnline) refreshData(),
      ]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
      return false;
    }
  }

  Future<void> _trySyncPendingActions() async {
    if (_syncingActions) return;
    _syncingActions = true;
    try {
      final actions = await LocalDbattendance.instance.pendingActions();
      if (actions.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');
      if (token == null) {
        debugPrint("Missing token for syncing actions");
        return;
      }

      for (final a in actions) {
        final id = a['id'] as int?;
        final action = a['action'] as String?;
        final selfie = a['selfie'] as String?;

        if (id == null || action == null) {
          debugPrint("Invalid action data: id=$id, action=$action");
          if (id != null) {
            await LocalDbattendance.instance.markAsFailed(id);
          }
          print(
              "=====================> Failed to process action: id=$id, action=$action");
          continue;
        }

        final uri = action == 'startWork'
            ? Uri.parse("https://salesrep.esanchaya.com/api/start_work")
            : Uri.parse("https://salesrep.esanchaya.com/api/end_work");

        try {
          final resp = await http.post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "params": {"token": token, "selfie": selfie}
            }),
          );

          if (resp.statusCode == 200) {
            final result = jsonDecode(resp.body)['result'];
            if (result?['success'] == true) {
              await LocalDbattendance.instance.markAsSynced(id);
            } else {
              await LocalDbattendance.instance.markAsFailed(id);
            }
          } else {
            debugPrint("Server error ${resp.statusCode} for action $action");
            await LocalDbattendance.instance.markAsFailed(id);
          }
        } catch (e) {
          debugPrint("Error syncing action $action: $e");
          await LocalDbattendance.instance.markAsFailed(id);
        }
      }
    } catch (e) {
      debugPrint("Error syncing pending actions: $e");
    } finally {
      _syncingActions = false;
    }
  }

  Future<void> _cacheAgencies(List<AgencyData> agencies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_agencies',
        jsonEncode(agencies.map((a) => a.toJson()).toList()));
  }

  Future<List<AgencyData>> _loadCachedAgencies() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_agencies');
    if (cached == null) return [];
    return (jsonDecode(cached) as List<dynamic>)
        .map((item) => AgencyData.fromJson(item))
        .toList();
  }

  Future<void> _loadCachedAgenciesOrDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUnit = prefs.getString('unit');
    final cachedAgencies = await _loadCachedAgencies();
    final pendingAssignments =
        await LocalDbAgency.instance.getPendingAssignments();

    // Create a list to hold all agencies (cached + pending)
    final List<AgencyData> combinedAgencies = List.from(cachedAgencies);

    // Add pending assignments (new agencies) to the list
    for (var assignment in pendingAssignments) {
      final extraData = assignment['extraData'] as Map<String, dynamic>?;
      if (extraData != null) {
        combinedAgencies.add(AgencyData(
          id: 'pending_${assignment['pinLocationId']}_${assignment['userId']}',
          locationName:
              extraData['location_name'] as String? ?? 'Pending Agency',
          code: extraData['code'] as String? ?? 'PENDING',
          unit: extraData['unit_name'] as String? ?? storedUnit ?? 'N/A',
          phone: extraData['phone'] as String?,
        ));
      }
    }

    // Ensure "Other Agency" is always available
    if (!combinedAgencies.any((agency) => agency.id == 'other_agency')) {
      combinedAgencies.add(AgencyData(
        id: 'other_agency',
        locationName: 'Other Agency',
        code: 'OTHER',
        unit: storedUnit ?? 'N/A',
        phone: null,
      ));
    }

    if (mounted) {
      setState(() {
        _agencyList = combinedAgencies;
        _isLoadingAgencies = false;
      });
    }

    if (combinedAgencies.length == 1 &&
        combinedAgencies.first.id == 'other_agency') {
      _showErrorSnackBar(
          "Offline mode: No cached agencies. Using default agency.");
    } else {
      _showSuccessSnackBar(
          "Offline mode: Loaded ${combinedAgencies.length} agencies.");
    }
  }

  Future<void> fetchAgencies() async {
    if (!mounted) return;

    setState(() => _isLoadingAgencies = true);

    final isOnline = await _isOnline();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final storedUnit = prefs.getString('unit');

    if (!isOnline) {
      debugPrint(
          "Offline mode: Skipping agency fetch, using cached or default agency list");
      await _loadCachedAgenciesOrDefault();
      return;
    }

    if (token == null) {
      _showErrorSnackBar("Missing token");
      setState(() => _isLoadingAgencies = false);
      return;
    }

    if (storedUnit == null || storedUnit.isEmpty) {
      _showErrorSnackBar("No unit assigned to this user");
      await _loadCachedAgenciesOrDefault();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/all_pin_locations"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final agencyModel = AgencyModel.fromJson(data);
        if (agencyModel.result?.success == true) {
          final uniqueAgencies = <String, AgencyData>{};
          for (var agency in agencyModel.result?.data ?? []) {
            if (agency.id != null &&
                agency.unit?.toLowerCase() == storedUnit.toLowerCase()) {
              uniqueAgencies[agency.id.toString()] = agency;
            }
          }

          uniqueAgencies['other_agency'] = AgencyData(
            id: 'other_agency',
            locationName: 'Other Agency',
            code: 'OTHER',
            unit: storedUnit,
            phone: null,
          );

          if (mounted) {
            setState(() {
              _agencyList = uniqueAgencies.values.toList();
              _isLoadingAgencies = false;
            });
            await _cacheAgencies(_agencyList); // Cache the fetched agencies
          }
        } else {
          _showErrorSnackBar("Failed to fetch agency list");
          await _loadCachedAgenciesOrDefault();
        }
      } else {
        _showErrorSnackBar("Failed to fetch agencies: ${response.statusCode}");
        await _loadCachedAgenciesOrDefault();
      }
    } catch (e) {
      debugPrint("Error fetching agencies: $e");
      _showErrorSnackBar("Error fetching agencies");
      await _loadCachedAgenciesOrDefault();
    }
  }

  Future<void> assignPinLocation() async {
    if (_selectedAgencyId == null) {
      _showErrorSnackBar("Please select an agency first");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      _showErrorSnackBar("Missing required data");
      return;
    }

    final isOffline = !(await _isOnline());

    if (_selectedAgencyId == 'other_agency') {
      if (_agencyNameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _codeController.text.isEmpty ||
          _unitController.text.isEmpty) {
        _showErrorSnackBar("Please fill all agency details");
        return;
      }

      try {
        await LocalDbAgency.instance.insertPendingAssignment(
          userId,
          -1,
          extraData: {
            "code": _codeController.text,
            "location_name": _agencyNameController.text,
            "phone": _phoneController.text,
            "unit_name": _unitController.text,
          },
        );
        _showSuccessSnackBar("New agency saved offline. Will sync later.");
        _clearAgencyFields();
        await _loadCachedAgenciesOrDefault(); // Refresh _agencyList
      } catch (e) {
        debugPrint("Error saving offline agency: $e");
        _showErrorSnackBar("Error saving offline agency");
      }
      return;
    }

    if (_selectedAgencyId!.startsWith('pending_')) {
      try {
        await LocalDbAgency.instance.insertPendingAssignment(
          userId,
          -1,
          extraData: {
            "code": _codeController.text.isNotEmpty
                ? _codeController.text
                : _selectedAgency?.code,
            "location_name": _agencyNameController.text.isNotEmpty
                ? _agencyNameController.text
                : _selectedAgency?.locationName,
            "phone": _phoneController.text.isNotEmpty
                ? _phoneController.text
                : _selectedAgency?.phone,
            "unit_name": _unitController.text.isNotEmpty
                ? _unitController.text
                : _selectedAgency?.unit,
          },
        );
        _showSuccessSnackBar(
            "Pending agency assignment saved offline. Will sync later.");
        _clearAgencyFields();
        await _loadCachedAgenciesOrDefault(); // Refresh _agencyList
      } catch (e) {
        debugPrint("Error saving offline pending agency assignment: $e");
        _showErrorSnackBar("Error saving offline assignment");
      }
      return;
    }

    final pinLocationId = int.tryParse(_selectedAgencyId!);
    if (pinLocationId == null) {
      _showErrorSnackBar("Invalid agency ID");
      return;
    }

    if (isOffline) {
      try {
        await LocalDbAgency.instance
            .insertPendingAssignment(userId, pinLocationId);
        _showSuccessSnackBar("Assignment saved offline. Will sync later.");
        _clearAgencyFields();
        await _loadCachedAgenciesOrDefault(); // Refresh _agencyList
      } catch (e) {
        debugPrint("Error saving offline assignment: $e");
        _showErrorSnackBar("Error saving offline assignment");
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/Pin_location_asin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "user_id": userId,
            "pin_lo_id": pinLocationId,
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result['success'] == true) {
          _showSuccessSnackBar("Agency successfully assigned");
          await refreshData();
        } else {
          _showErrorSnackBar(
              "Failed to assign agency: ${result['message'] ?? 'Unknown error'}");
        }
      } else {
        _showErrorSnackBar("Failed to assign agency: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error assigning agency: $e");
      _showErrorSnackBar("Error assigning agency");
    }
  }

  void _clearAgencyFields() {
    if (mounted) {
      setState(() {
        _selectedAgencyId = null;
        _agencyNameController.clear();
        _phoneController.clear();
        _codeController.clear();
        _unitController.clear();
        _selectedAgencyController.clear();
        _selectedAgency = null;
      });
    }
  }

  Future<void> fetchSelfieTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      _showErrorSnackBar("Missing token or user ID");
      return;
    }

    if (!(await _isOnline())) {
      debugPrint("Offline mode: Skipping selfie times fetch");
      _showErrorSnackBar("Offline mode: Selfie times not fetched.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/user/today_selfies"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token, "user_id": userId}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selfieData = SelfieTimesResponse.fromJson(data);
        if (selfieData.success) {
          setState(() {
            _selfieSessions = selfieData.sessions ?? [];
          });
        } else {
          _showErrorSnackBar("Failed to fetch selfie times");
        }
      } else {
        _showErrorSnackBar(
            "Failed to fetch selfie times: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching selfie times: $e");
      _showErrorSnackBar("Error fetching selfie times");
    }
  }

  Future<void> loadWorkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isWorking = prefs.getBool('isWorking') ?? false;
      });
    } catch (e) {
      debugPrint("Error loading work status: $e");
      _showErrorSnackBar("Error loading work status");
    }
  }

  Future<void> saveWorkStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isWorking', status);
    } catch (e) {
      debugPrint("Error saving work status: $e");
    }
  }

  Future<void> startWork() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (photo == null) {
        _showErrorSnackBar("Photo required");
        return;
      }

      final bytes = await photo.readAsBytes();
      _startWorkPhotoBase64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');

      if (token == null) {
        _showErrorSnackBar("Missing or invalid API key");
        return;
      }

      if (!await _isOnline()) {
        await LocalDbattendance.instance.enqueueAction(
          type: PendingActionType.startWork,
          selfieBase64: _startWorkPhotoBase64,
        );
        await saveWorkStatus(true);
        setState(() => isWorking = true);
        _showSuccessSnackBar("Work started (offline). Will sync when online.");
        return;
      }

      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/start_work"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token, "selfie": _startWorkPhotoBase64}
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result['success'] == true) {
          setState(() => isWorking = true);
          await saveWorkStatus(true);
          _showSuccessSnackBar("Work started");
          await fetchSelfieTimes();
        } else {
          _showErrorSnackBar(
              "Failed to start work: ${result['message'] ?? 'Unknown error'}");
        }
      } else {
        await LocalDbattendance.instance.enqueueAction(
          type: PendingActionType.startWork,
          selfieBase64: _startWorkPhotoBase64,
        );
        await saveWorkStatus(true);
        setState(() => isWorking = true);
        _showSuccessSnackBar(
            "Work started (queued). Server ${response.statusCode}. Will sync later.");
      }
    } catch (e) {
      debugPrint("Error starting work: $e");
      await LocalDbattendance.instance.enqueueAction(
        type: PendingActionType.startWork,
        selfieBase64: _startWorkPhotoBase64,
      );
      await saveWorkStatus(true);
      setState(() => isWorking = true);
      _showSuccessSnackBar("Work started (offline). Sync pending.");
    }
  }

  Future<void> stopWork() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (photo == null) {
        _showErrorSnackBar("Photo required");
        return;
      }

      final bytes = await photo.readAsBytes();
      final photoBase64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');

      if (token == null) {
        _showErrorSnackBar("Missing or invalid API key");
        return;
      }

      if (!await _isOnline()) {
        await LocalDbattendance.instance.enqueueAction(
          type: PendingActionType.stopWork,
          selfieBase64: photoBase64,
        );
        await saveWorkStatus(false);
        setState(() {
          isWorking = false;
          _startWorkPhotoBase64 = null;
        });
        _showSuccessSnackBar("Work stopped (offline). Will sync when online.");
        return;
      }

      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/end_work"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token, "selfie": photoBase64}
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result['success'] == true) {
          setState(() {
            isWorking = false;
            _startWorkPhotoBase64 = null;
          });
          await saveWorkStatus(false);
          _showSuccessSnackBar("Work stopped");
          await fetchSelfieTimes();
        } else {
          _showErrorSnackBar(
              "Failed to stop work: ${result['message'] ?? 'Unknown error'}");
        }
      } else {
        await LocalDbattendance.instance.enqueueAction(
          type: PendingActionType.stopWork,
          selfieBase64: photoBase64,
        );
        await saveWorkStatus(false);
        setState(() {
          isWorking = false;
          _startWorkPhotoBase64 = null;
        });
        _showSuccessSnackBar(
            "Work stopped (queued). Server ${response.statusCode}. Will sync later.");
      }
    } catch (e) {
      debugPrint("Error stopping work: $e");
      await LocalDbattendance.instance.enqueueAction(
        type: PendingActionType.stopWork,
        selfieBase64: null,
      );
      await saveWorkStatus(false);
      setState(() {
        isWorking = false;
        _startWorkPhotoBase64 = null;
      });
      _showSuccessSnackBar("Work stopped (offline). Sync pending.");
    }
  }

  void startTokenValidation() {
    _sessionCheckTimer?.cancel();
    validateToken();
    _sessionCheckTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => validateToken());
  }

  Future<void> validateToken() async {
    if (!(await _isOnline())) {
      debugPrint("Offline mode: Skipping token validation");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null) {
      forceLogout("Session expired or invalid token.");
      return;
    }

    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      if (!(await _isOnline())) {
        debugPrint("Offline during token validation, skipping retry");
        return;
      }
      try {
        final response = await http.post(
          Uri.parse("https://salesrep.esanchaya.com/token_validation"),
          headers: {
            "Content-Type": "application/json",
            "Cookie": "session_id=${sessionId ?? ''}",
          },
          body: jsonEncode({
            "params": {"token": token}
          }),
        );

        final result = jsonDecode(response.body)['result'];
        if (result['success'] != true) {
          forceLogout(
              "Session expired. You may have logged in on another device.");
        }
        return;
      } catch (e) {
        retryCount++;
        debugPrint("Token validation failed (attempt $retryCount): $e");
        if (retryCount >= maxRetries) {
          forceLogout("Error validating session after $maxRetries attempts.");
        } else {
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }
  }

  Future<void> syncPendingForms() async {
    if (!(await _isOnline())) {
      _showErrorSnackBar(
          "No internet connection. Please connect to sync forms.");
      return;
    }

    setState(() => _isSyncing = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final pendingFormsJson = prefs.getString('pending_forms');

    if (token == null) {
      _showErrorSnackBar("Missing or invalid token");
      setState(() => _isSyncing = false);
      return;
    }

    if (pendingFormsJson == null || pendingFormsJson.isEmpty) {
      _showSuccessSnackBar("No pending forms to sync");
      await prefs.remove('pending_forms');
      setState(() => _isSyncing = false);
      return;
    }

    try {
      final List<dynamic> pendingForms = jsonDecode(pendingFormsJson);
      bool allSyncedSuccessfully = true;

      for (var form in pendingForms) {
        try {
          final response = await http.post(
            Uri.parse("https://salesrep.esanchaya.com/api/customer_form"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "params": {
                "token": token,
                ...form,
              }
            }),
          );

          if (response.statusCode == 200) {
            final result = jsonDecode(response.body)['result'];
            if (result['success'] != true) {
              allSyncedSuccessfully = false;
              _showErrorSnackBar(
                  "Failed to sync form: ${result['message'] ?? 'Unknown error'}");
            }
          } else {
            allSyncedSuccessfully = false;
            _showErrorSnackBar("Failed to sync form: ${response.statusCode}");
          }
        } catch (e) {
          debugPrint("Error syncing form: $e");
          allSyncedSuccessfully = false;
          _showErrorSnackBar("Error syncing form");
        }
      }

      if (allSyncedSuccessfully) {
        await prefs.remove('pending_forms');
        _showSuccessSnackBar("All forms synced successfully");
      } else {
        _showErrorSnackBar("Some forms failed to sync");
      }

      await refreshData();
    } catch (e) {
      debugPrint("Error syncing forms: $e");
      _showErrorSnackBar("Error syncing forms");
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> syncPendingAssignments() async {
    if (!(await _isOnline())) {
      debugPrint("Offline mode: Skipping assignment sync");
      _showErrorSnackBar("No internet connection. Cannot sync assignments.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      _showErrorSnackBar("Missing token or user ID");
      return;
    }

    final pendingAssignments =
        await LocalDbAgency.instance.getPendingAssignments();
    if (pendingAssignments.isEmpty) {
      debugPrint("No pending assignments to sync");
      _showSuccessSnackBar("No pending assignments to sync");
      return;
    }

    bool allSyncedSuccessfully = true;

    for (int i = 0; i < pendingAssignments.length; i++) {
      final assignment = pendingAssignments[i];
      final pinLocationId = assignment['pinLocationId'] as int;
      final extraData = assignment['extraData'] as Map<String, dynamic>?;

      try {
        if (pinLocationId == -1 && extraData != null) {
          final response = await http.post(
            Uri.parse("https://salesrep.esanchaya.com/api/create_pin_location"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "params": {
                "token": token,
                "code": extraData['code'],
                "location_name": extraData['location_name'],
                "phone": extraData['phone'],
                "unit_name": extraData['unit_name'],
              }
            }),
          );

          if (response.statusCode == 200) {
            final result = jsonDecode(response.body)['result'];
            if (result['success'] == true) {
              final newPinLocationId = result['pin_location_id'] as int?;
              if (newPinLocationId != null) {
                await _assignPinLocation(token, userId, newPinLocationId);
                await LocalDbAgency.instance.clearPendingAssignment(i);
              }
            } else {
              allSyncedSuccessfully = false;
              debugPrint(
                  "Failed to sync new agency: ${result['message'] ?? 'Unknown error'}");
            }
          } else {
            allSyncedSuccessfully = false;
            debugPrint("Failed to sync new agency: ${response.statusCode}");
          }
        } else {
          await _assignPinLocation(token, userId, pinLocationId);
          await LocalDbAgency.instance.clearPendingAssignment(i);
        }
      } catch (e) {
        debugPrint("Error syncing assignment: $e");
        allSyncedSuccessfully = false;
      }
    }

    if (allSyncedSuccessfully) {
      _showSuccessSnackBar("All assignments synced successfully");
      await fetchAgencies();
      await _loadCachedAgenciesOrDefault();
    } else {
      _showErrorSnackBar("Some assignments failed to sync");
      await _loadCachedAgenciesOrDefault();
    }
  }

  Future<void> _assignPinLocation(
      String token, int userId, int pinLocationId) async {
    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/api/Pin_location_asin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "params": {
          "token": token,
          "user_id": userId,
          "pin_lo_id": pinLocationId,
        }
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['result'];
      if (result['success'] != true) {
        debugPrint(
            "Failed to assign agency: ${result['message'] ?? 'Unknown error'}");
      }
    } else {
      debugPrint("Failed to assign agency: ${response.statusCode}");
    }
  }

  void forceLogout(String message) async {
    debugPrint("Force Logout: $message");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      _showErrorSnackBar(message);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Loginscreen()),
        (route) => false,
      );
    }
  }

  Future<void> refreshData() async {
    setState(() => _isLoading = true);
    try {
      final isOnline = await _isOnline();
      await Future.wait([
        loadOnedayHistory(),
        if (isOnline) fetchFullRouteMap(),
        if (isOnline) fetchSelfieTimes(),
        if (isOnline) fetchAgencies(),
      ]);
    } catch (e) {
      debugPrint("Error refreshing data: $e");
      _showErrorSnackBar("Error refreshing data");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchFullRouteMap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      _showErrorSnackBar("Missing token or user ID");
      return;
    }

    if (!(await _isOnline())) {
      debugPrint("Offline mode: Skipping route map fetch");
      _showErrorSnackBar("Offline mode: Route map not fetched.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/user_root_maps_by_stage"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {"user_id": userId, "token": token}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routeMap = RouteMap.fromJson(data);
        final today = DateTime.now();
        final todayOnlyRoutes = routeMap.result?.assigned?.where((assigned) {
          final routeDate = DateTime.tryParse(assigned.date ?? '');
          return routeDate != null &&
              routeDate.year == today.year &&
              routeDate.month == today.month &&
              routeDate.day == today.day;
        }).toList();

        Assigned? latestRoute;
        if (todayOnlyRoutes != null && todayOnlyRoutes.isNotEmpty) {
          todayOnlyRoutes.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          latestRoute = todayOnlyRoutes.first;
        }

        setState(() {
          fullRouteMap = routeMap;
          fullRouteMap?.result?.assigned =
              latestRoute != null ? [latestRoute] : [];
        });
      } else {
        _showErrorSnackBar("Failed to fetch route map: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching full route map: $e");
      _showErrorSnackBar("Error fetching route map");
    }
  }

  Future<void> loadAgentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        agentname = prefs.getString('agentname') ?? 'Unknown';
      });
    } catch (e) {
      debugPrint("Error loading agent data: $e");
      _showErrorSnackBar("Error loading agent data");
    }
  }

  Future<void> loadOnedayHistory() async {
    try {
      final result = await _onedayagent.fetchOnedayHistory();
      setState(() {
        records = (result['records'] as List<dynamic>?)?.cast<Record>() ?? [];
        offerAcceptedCount = result['offer_accepted'] as int? ?? 0;
        offerRejectedCount = result['offer_rejected'] as int? ?? 0;
        alreadySubscribedCount = result['already_subscribed'] as int? ?? 0;
      });
    } catch (e) {
      debugPrint("Error loading one day history: $e");
      _showErrorSnackBar("Error loading history");
    }
  }

  void _showSelfieDialog(String? base64Image, String title) {
    if (base64Image == null || base64Image.isEmpty) {
      _showErrorSnackBar("No selfie available");
      return;
    }

    final cleanBase64 = base64Image.startsWith('data:image')
        ? base64Image.split(',')[1]
        : base64Image;

    try {
      base64Decode(cleanBase64);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Image.memory(
              base64Decode(cleanBase64),
              width: 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Text(
                  "Error loading image",
                  style: TextStyle(color: Colors.red)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error decoding base64 image: $e");
      _showErrorSnackBar("Invalid image data");
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(localizations.salesrepresentative),
            Text("${localizations.welcome} $agentname",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const agentProfile())),
          ),
        ],
      ),
      drawer: _buildDrawer(localeProvider, localizations),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "customer_form",
            backgroundColor: Colors.white,
            onPressed: isWorking
                ? () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Coustmer()));
                    await refreshData();
                  }
                : null,
            label: Text(localizations.customerform,
                style:
                    TextStyle(color: isWorking ? Colors.black : Colors.grey)),
            icon: Icon(Icons.add_box_outlined,
                color: isWorking ? Colors.black : Colors.grey),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "sync_offline_forms",
            backgroundColor: _isSyncing ? Colors.grey : Colors.blue,
            onPressed: _isSyncing ? null : syncPendingForms,
            label: Text(
              _isSyncing ? "Syncing..." : "Sync Offline Forms",
              style: const TextStyle(color: Colors.white),
            ),
            icon: Icon(_isSyncing ? Icons.hourglass_empty : Icons.sync,
                color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "work_status",
            backgroundColor: isWorking ? Colors.red : Colors.green,
            onPressed: isWorking ? stopWork : startWork,
            label: Text(
                isWorking ? localizations.stopwork : localizations.startwork,
                style: const TextStyle(color: Colors.white)),
            icon: Icon(isWorking ? Icons.stop : Icons.play_arrow,
                color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Center(
                        child: Text(dateController.text,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 20),
                    Center(
                        child: Text(
                            "${localizations.nameofthestaff}: $agentname",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Onedayhistory())),
                      child: _buildInfoRow(localizations.houseVisited,
                          "${records.length} House${records.length == 1 ? '' : 's'} Visited"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SavedFormsScreen()));
                        },
                        child: const Text("View offline forms")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OfflineAttendanceView()));
                        },
                        child: const Text("View offline attendance")),
                    const SizedBox(height: 10),
                    Center(child: Text(localizations.agency)),
                    const SizedBox(height: 10),
                    Autocomplete<AgencyData>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (_agencyList.isEmpty) {
                          return [
                            AgencyData(
                              id: 'other_agency',
                              locationName: 'Other Agency',
                              code: 'OTHER',
                              unit: 'N/A',
                              phone: null,
                            )
                          ];
                        }
                        if (textEditingValue.text.isEmpty) {
                          return _agencyList;
                        }
                        final query = textEditingValue.text.toLowerCase();
                        final queryWords = query.split(' ');
                        return _agencyList
                            .where((agency) => queryWords.any((word) =>
                                (agency.locationName
                                        ?.toLowerCase()
                                        .contains(word) ??
                                    false) ||
                                (agency.code?.toLowerCase().contains(word) ??
                                    false)))
                            .toList();
                      },
                      displayStringForOption: (AgencyData agency) =>
                          agency.locationName ?? agency.code ?? 'Unknown',
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        fieldTextEditingController.text =
                            _selectedAgencyController.text;
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            labelText: localizations.agency,
                            hintText: _isLoadingAgencies
                                ? localizations.loadingagencies
                                : 'localizations.searchorselectagency',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedAgencyId = null;
                              _selectedAgencyController.text = value;
                            });
                          },
                          enabled: true,
                        );
                      },
                      onSelected: (AgencyData selection) {
                        setState(() {
                          _selectedAgencyId = selection.id.toString();
                          _selectedAgencyController.text =
                              selection.locationName ??
                                  selection.code ??
                                  'Unknown';
                          _agencyNameController.text =
                              selection.locationName ?? '';
                          _phoneController.text = selection.phone ?? '';
                          _codeController.text = selection.code ?? '';
                          _unitController.text = selection.unit ?? '';
                          _selectedAgency = selection;
                        });
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<AgencyData> onSelected,
                          Iterable<AgencyData> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final AgencyData option =
                                      options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () => onSelected(option),
                                    child: ListTile(
                                      title: Text(
                                        option.locationName ??
                                            option.code ??
                                            'Unknown',
                                        style: TextStyle(
                                          color: option.id?.startsWith(
                                                      'pending_') ??
                                                  false
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "[${option.code ?? ''}]${option.id?.startsWith('pending_') ?? false ? ' (Offline)' : ''}",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_selectedAgencyId == 'other_agency') ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _agencyNameController,
                        decoration: InputDecoration(
                          labelText: localizations.agencyname ?? 'Agency Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.business),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'localizations.pleaseenteragencyname' ??
                                'Please enter agency name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: localizations.phone ?? 'Phone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'localizations.pleaseenterphone' ??
                                'Please enter phone number'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'localizations.code' ?? 'Code',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.code),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'localizations.pleaseentercode' ??
                                'Please enter code'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: 'localizations.unit' ?? 'Unit',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.apartment),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'localizations.pleaseenterunit' ??
                                'Please enter unit'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoadingAgencies ? null : assignPinLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(localizations.assignagency,
                          style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    Center(
                        child: _buildSectionTitle(localizations.shiftdetails)),
                    const SizedBox(height: 13),
                    _buildShiftDetails(localizations),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer(
      LocalizationProvider localeProvider, AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              children: [
                const Icon(Icons.account_circle, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(localizations.salesrepresentative,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          ListTile(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('English'),
                    Switch(
                      value: localeProvider.locale.languageCode == 'te',
                      onChanged: (value) => localeProvider.toggleLocale(),
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.blue,
                      activeTrackColor: Colors.green.shade200,
                      inactiveTrackColor: Colors.blue.shade200,
                    ),
                    const Text('తెలుగు'),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Historypage()));
                  },
                  child: const Text("Total History"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildShiftDetails(AppLocalizations localizations) {
    final today = DateTime.now();
    final todaySessions = _selfieSessions.where((session) {
      final startTime = DateTime.tryParse(session.startTime ?? '');
      return startTime != null &&
          startTime.year == today.year &&
          startTime.month == today.month &&
          startTime.day == today.day;
    }).toList();

    if (todaySessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)),
        child: Text(localizations.noshiftdataavailable,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return Column(
      children: todaySessions.asMap().entries.map((entry) {
        final index = entry.key;
        final session = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${localizations.session} ${index + 1}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (session.startTime != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showSelfieDialog(
                            session.startSelfie, localizations.startselfie),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Text(localizations.starttime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(session.startTime != null
                                  ? DateFormat('hh:mm a').format(
                                      DateTime.parse(session.startTime!))
                                  : "--"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (session.startTime != null && session.endTime != null)
                    const SizedBox(width: 12),
                  if (session.endTime != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showSelfieDialog(
                            session.endSelfie, localizations.endselfie),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Text(localizations.endtime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(session.endTime != null
                                  ? DateFormat('hh:mm a')
                                      .format(DateTime.parse(session.endTime!))
                                  : "--"),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (session.startTime != null && session.endTime != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(localizations.totalworkinghours,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(() {
                        final start = DateTime.tryParse(session.startTime!);
                        final end = DateTime.tryParse(session.endTime!);
                        if (start != null && end != null) {
                          final duration = end.difference(start);
                          return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
                        }
                        return "--";
                      }()),
                    ],
                  ),
                )
              else if (session.startTime != null && session.endTime == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(localizations.sessionongoing,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(localizations.workinprogressendtimenotset,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _sessionCheckTimer?.cancel();
    dateController.dispose();
    _agencyNameController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _unitController.dispose();
    _selectedAgencyController.dispose();
    super.dispose();
  }
}

class AgencyModel {
  final AgencyResult? result;

  AgencyModel({this.result});

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      result:
          json['result'] != null ? AgencyResult.fromJson(json['result']) : null,
    );
  }
}

class AgencyResult {
  final bool success;
  final List<AgencyData> data;

  AgencyResult({required this.success, required this.data});

  factory AgencyResult.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List<dynamic>? ?? [];
    return AgencyResult(
      success: json['success'] ?? false,
      data: dataList.map((item) => AgencyData.fromJson(item)).toList(),
    );
  }
}
