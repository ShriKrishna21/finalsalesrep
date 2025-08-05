import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/agent/agentaddrouite.dart';
import 'package:finalsalesrep/modelclasses/selfietimeresponse.dart' show SelfieTimesResponse, SelfieSession;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'package:finalsalesrep/modelclasses/routemap.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/agent/addextrapoint.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/agent/coustmerform.dart';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/agent/onedayhistory.dart';

class startworkselfiemodel {
  String? jsonrpc;
  Null? id;
  Result? result;

  startworkselfiemodel({this.jsonrpc, this.id, this.result});

  startworkselfiemodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class endworkselfiekmodel {
  String? jsonrpc;
  Null? id;
  Result? result;

  endworkselfiekmodel({this.jsonrpc, this.id, this.result});

  endworkselfiekmodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  bool? success;
  String? message;
  int? code;

  Result({this.success, this.message, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

class Agentscreen extends StatefulWidget {
  const Agentscreen({super.key});

  @override
  State<Agentscreen> createState() => _AgentscreenState();
}

class _AgentscreenState extends State<Agentscreen> {
  TextEditingController dateController = TextEditingController();
  String agentname = "";
  List<Record> records = [];
  bool _isLoading = true;
  bool isWorking = false;
  Timer? _sessionCheckTimer;
  RouteMap? fullRouteMap;


  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  List<SelfieSession> _selfieSessions = [];

  final Onedayagent _onedayagent = Onedayagent();

  @override
  void initState() {
    super.initState();
    startTokenValidation();
    dateController.text = DateFormat('EEE, MMM d, y').format(DateTime.now());
    loadAgentData();
    loadWorkStatus();
    refreshData();
    fetchSelfieTimes();
  }

  Future<void> fetchSelfieTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    debugPrint("🔍 Token: $token, UserId: $userId");

    if (token == null || userId == null) {
      debugPrint("❌ Missing token or userId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing token or user ID")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/user/today_selfies"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "user_id": userId,
          }
        }),
      );

      debugPrint("🔁 Selfie Times Status Code: ${response.statusCode}");
      debugPrint("🔁 Selfie Times Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("🔍 Parsed JSON: $data");

        if (data == null || data['result'] == null) {
          debugPrint("❌ Invalid response structure: Missing 'result' key");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid response from server")),
          );
          return;
        }

        final selfieData = SelfieTimesResponse.fromJson(data);

        debugPrint("🔍 SelfieTimesResponse: success=${selfieData.success}, "
            "sessions=${selfieData.sessions.map((s) => {
              'startTime': s.startTime,
              'endTime': s.endTime,
              'startSelfie': s.startSelfie != null ? '${s.startSelfie!.substring(0, s.startSelfie!.length > 50 ? 50 : s.startSelfie!.length)}...' : null,
              'endSelfie': s.endSelfie != null ? '${s.endSelfie!.substring(0, s.endSelfie!.length > 50 ? 50 : s.endSelfie!.length)}...' : null,
            }).toList()}");

        if (selfieData.success) {
          try {
            setState(() {
              _selfieSessions = selfieData.sessions;
            });
          } catch (e) {
            debugPrint("❌ Error in setState: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating UI: $e")),
            );
          }
        } else {
          debugPrint("❌ Selfie times fetch unsuccessful: ${selfieData.success}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch selfie times")),
          );
        }
      } else {
        debugPrint("❌ Failed to fetch selfie times: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch selfie times: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error fetching selfie times: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching selfie times: $e")),
      );
    }
  }

  Future<void> loadWorkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isWorking = prefs.getBool('isWorking') ?? false;
    });
  }

  Future<void> saveWorkStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWorking', status);
  }

  Future<void> startWork() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (photo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo required")),
        );
        return;
      }

      final bytes = await photo.readAsBytes();
      _startWorkPhotoBase64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');

      if (token == null || token.isEmpty) {
        debugPrint("❌ Missing or empty API key");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing or invalid API key")),
        );
        return;
      }

      debugPrint("📡 Hitting API: https://salesrep.esanchaya.com/api/start_work");
      debugPrint(
          "📦 Payload: {\"params\":{\"token\":\"$token\",\"selfie\":\"${_startWorkPhotoBase64!.substring(0, 50)}...\"}}");

      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/start_work"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "selfie": _startWorkPhotoBase64,
          }
        }),
      );

      debugPrint("🔁 Status Code: ${response.statusCode}");
      debugPrint("✅ Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result != null && result['success'] == true) {
          setState(() {
            isWorking = true;
          });
          await saveWorkStatus(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Work started")),
          );
          await fetchSelfieTimes();
        } else {
          final errorMessage = result?['message'] ?? 'Unknown error';
          debugPrint("❌ Failed to start work: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to start work: $errorMessage")),
          );
        }
      } else {
        debugPrint("❌ Failed to start work: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start work: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error starting work: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting work: $e")),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo required")),
        );
        return;
      }

      final bytes = await photo.readAsBytes();
      final photoBase64 = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');

      if (token == null || token.isEmpty) {
        debugPrint("❌ Missing or empty API key");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing or invalid API key")),
        );
        return;
      }

      debugPrint("📡 Hitting API: https://salesrep.esanchaya.com/api/end_work");
      debugPrint(
          "📦 Payload: {\"params\":{\"token\":\"$token\",\"selfie\":\"${photoBase64.substring(0, 50)}...\"}}");

      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/end_work"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "selfie": photoBase64,
          }
        }),
      );

      debugPrint("🔁 Status Code: ${response.statusCode}");
      debugPrint("✅ Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        if (result != null && result['success'] == true) {
          setState(() {
            isWorking = false;
            _startWorkPhotoBase64 = null;
          });
          await saveWorkStatus(false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Work stopped")),
          );
          await fetchSelfieTimes();
        } else {
          final errorMessage = result?['message'] ?? 'Unknown error';
          debugPrint("❌ Failed to stop work: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to stop work: $errorMessage")),
          );
        }
      } else {
        debugPrint("❌ Failed to stop work: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to stop work: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error stopping work: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error stopping work: $e")),
      );
    }
  }

  void startTokenValidation() {
    validateToken();
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => validateToken());
  }

  Future<void> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');
    if (token == null || token.isEmpty) {
      forceLogout("Session expired or invalid token.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/token_validation"),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=$sessionId",
        },
        body: jsonEncode({
          "params": {"token": token}
        }),
      );
      debugPrint("🔁 Token Validation Response: ${response.body}");
      final result = jsonDecode(response.body)['result'];
      if (result == null || result['success'] != true) {
        forceLogout(
            "Session expired. You may have logged in on another device.");
      }
    } catch (e) {
      forceLogout("Error validating session. Please log in again.");
    }
  }

  void forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Loginscreen()),
        (route) => false);
  }

  Future<void> refreshData() async {
    setState(() => _isLoading = true);
    await loadOnedayHistory();

  Future<void> loadAgentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        agentname = prefs.getString('agentname') ?? '';
      });
    } catch (e) {

    }
  }

  Future<void> _uploadSelfie(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or missing token/user ID')),
      );
      return;
    }

    String apiUrl;
    switch (type) {
      case 'login':
        apiUrl = "https://salesrep.esanchaya.com/api/start_work";
        break;
      case 'logout':
        apiUrl = "https://salesrep.esanchaya.com/api/end_work";
        break;
      default:
        apiUrl = "https://salesrep.esanchaya.com/api/user/today_selfies";
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "user_id": userId,
            "token": token,
            "type": type == 'login' || type == 'logout' ? null : type,
            "selfie": base64Image,
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        bool success = false;
        String message = '';

        if (type == 'login') {
          final selfieModel = startworkselfiemodel.fromJson(responseData);
          success = selfieModel.result?.success ?? false;
          message = selfieModel.result?.message ?? 'Login selfie uploaded';
        } else if (type == 'logout') {
          final selfieModel = endworkselfiekmodel.fromJson(responseData);
          success = selfieModel.result?.success ?? false;
          message = selfieModel.result?.message ?? 'Logout selfie uploaded';
        } else {
          success = responseData['result']?['success'] ?? false;
          message =
              responseData['result']?['message'] ?? 'Selfie $type uploaded';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success
                  ? '$message successfully'
                  : 'Failed to upload selfie: $message')),
        );
        await refreshData();
      } else {
        debugPrint("Upload failed: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload selfie: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Error uploading selfie: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading selfie: $e')),
      );
    }
  }

  Future<void> loadOnedayHistory() async {
    try {
      final result = await _onedayagent.fetchOnedayHistory();
      setState(() {
        records = (result['records'] as List<dynamic>?)?.cast<Record>() ?? [];
        offerAcceptedCount = result['offer_accepted'] ?? 0;
        offerRejectedCount = result['offer_rejected'] ?? 0;
        alreadySubscribedCount = result['already_subscribed'] ?? 0;
      });
    } catch (e) {
      debugPrint("❌ Error loading one day history: $e");
    }
  }

  void _showSelfieDialog(String? base64Image, String title) {
    if (base64Image == null || base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No selfie available")),
      );
      return;
    }

    // Remove data URL prefix if present
    final cleanBase64 = base64Image.startsWith('data:image')
        ? base64Image.split(',')[1]
        : base64Image;

    try {
      // Validate base64 string
      base64Decode(cleanBase64);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  base64Decode(cleanBase64),
                  width: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "Error loading image",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
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
      debugPrint("❌ Error decoding base64 image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid image data")),
      );
    }
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Sales Representative")),
            Center(
              child: Text("Welcome $agentname",
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const agentProfile())),
          )
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(

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
                        "Name of the Staff: $agentname",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Onedayhistory()),
                      ),
                      child: _buildInfoRow("Houses Visited",
                          "${records.length} House${records.length == 1 ? '' : 's'} Visited"),
                    ),
                    const SizedBox(height: 10),
                    const Text("Agency"),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter agency name or code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      onChanged: (value) {
                        debugPrint("🔍 Entered agency: $value");
                      },
                    ),

                    const SizedBox(height: 8),
                    const SizedBox(height: 30),
                    Center(child: _buildSectionTitle("Reports")),
                    _buildBulletPoint("Already Subscribed: $alreadySubscribedCount"),
                    const SizedBox(height: 40),
                    Center(child: _buildSectionTitle("Shift Details")),
                    const SizedBox(height: 10),
                    if (_selfieSessions.isNotEmpty)
                      ..._selfieSessions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final session = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Session ${index + 1}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (session.startTime != null)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showSelfieDialog(
                                            session.startSelfie, "Start Selfie"),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            border: Border.all(color: Colors.green),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Start Time",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                session.startTime != null
                                                    ? DateFormat('hh:mm a').format(
                                                        DateTime.parse(
                                                            session.startTime!))
                                                    : "--",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (session.startTime != null &&
                                      session.endTime != null)
                                    const SizedBox(width: 12),
                                  if (session.endTime != null)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showSelfieDialog(
                                            session.endSelfie, "End Selfie"),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            border: Border.all(color: Colors.red),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              const Text(
                                                "End Time",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                session.endTime != null
                                                    ? DateFormat('hh:mm a').format(
                                                        DateTime.parse(
                                                            session.endTime!))
                                                    : "--",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (session.startTime != null &&
                                  session.endTime != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Total Working Hours",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        () {
                                          final start = DateTime.tryParse(
                                              session.startTime!);
                                          final end = DateTime.tryParse(
                                              session.endTime!);
                                          if (start != null && end != null) {
                                            final duration =
                                                end.difference(start);
                                            return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
                                          }
                                          return "--";
                                        }(),
                                      ),
                                    ],
                                  ),
                                )
                              else if (session.startTime != null &&
                                  session.endTime == null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Session Ongoing",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Work in progress, end time not set",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "No shift data available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 60),
                const SizedBox(height: 10),
                Text(agentname, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History Page"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Historypage())),
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

  Widget _buildBulletPoint(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 18)),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          ],
        ),
      );
}