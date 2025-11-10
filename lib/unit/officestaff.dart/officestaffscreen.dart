// lib/unit/officestaff.dart/officestaffscreen.dart
import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/offline/dbhelper.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/offline/offlineagentsscreen.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/officestaff.dart/viewcreatedagents.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class OfficeStaffScreen extends StatefulWidget {
  const OfficeStaffScreen({super.key});

  @override
  State<OfficeStaffScreen> createState() => _OfficeStaffScreenState();
}

class _OfficeStaffScreenState extends State<OfficeStaffScreen>
    with WidgetsBindingObserver {
  String staffName = '';
  String unitName = '';
  Timer? _sessionCheckTimer;
  bool _isOnline = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadStaffInfo();
    _checkInitialConnectivity();
    _startConnectivityListener();
    _startTokenValidation();

    // Auto sync after app starts
    Future.delayed(const Duration(seconds: 2), _trySyncNow);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _trySyncNow(); // Sync again when app comes to foreground
    }
  }

  Future<void> loadStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      staffName = prefs.getString('name') ?? 'Office Staff';
      unitName = prefs.getString('unit') ?? '';
    });
  }

  Future<void> _trySyncNow() async {
    final results = await Connectivity().checkConnectivity();
    if (_hasInternet(results)) {
      await _syncOfflineAgents();
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final connected = _hasInternet(results);
    setState(() => _isOnline = connected);
    if (!connected) _showNoInternetSnackBar();
  }

  void _startConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) async {
      final nowOnline = _hasInternet(results);
      if (nowOnline && !_isOnline && mounted) {
        setState(() => _isOnline = true);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Back online"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _startTokenValidation();
        await _syncOfflineAgents();
      } else if (!nowOnline && mounted) {
        setState(() => _isOnline = false);
        _showNoInternetSnackBar();
        _stopTokenValidation();
      }
    });
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  void _showNoInternetSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("No internet connection"),
        backgroundColor: Colors.red,
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: _trySyncNow,
        ),
      ),
    );
  }

  // 🔒 Token validation every 20 seconds (only when online)
  void _startTokenValidation() {
    _sessionCheckTimer?.cancel();
    if (!_isOnline) return;
    _validateToken();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (_isOnline && mounted) await _validateToken();
    });
  }

  void _stopTokenValidation() => _sessionCheckTimer?.cancel();

  Future<void> _validateToken() async {
    if (!_isOnline) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    if (token == null || token.isEmpty) return;

    try {
      final response = await http
          .post(
            Uri.parse("https://salesrep.esanchaya.com/token_validation"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"params": {"token": token}}),
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);
      final result = data['result'];

      if (result != null && result['success'] == false) {
        _forceLogout(
            "Session expired. You may have logged in on another device.");
      }
    } on TimeoutException {
      debugPrint("⏳ Token validation timed out — staying logged in.");
    } catch (e) {
      debugPrint("⚠️ Token validation failed: $e");
      // Don’t logout on offline or timeout
    }
  }

  void _forceLogout(String message) async {
    _stopTokenValidation();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
  }

  // 🛰️ Auto-sync offline-created staff
  Future<void> _syncOfflineAgents() async {
    final pending = await DBHelper().getAllPending();
    if (pending.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unit = prefs.getString('unit');
    if (token == null || token.isEmpty) return;

    int synced = 0;
    for (var agent in pending) {
      try {
        final response = await http
            .post(
              Uri.parse(CommonApiClass.CreateAgent),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "params": {
                  "token": token,
                  "name": agent['name'],
                  "email": agent['email'],
                  "password": agent['password'],
                  "role": "agent",
                  "aadhar_number": agent['aadhar_number'] ?? "",
                  "pan_number": agent['pan_number'] ?? "",
                  "state": agent['state'] ?? "",
                  "status": "un_activ",
                  "phone": agent['phone'] ?? "",
                  "unit_name": unit ?? "",
                  "aadhar_base64": agent['aadhar_base64'] ?? "",
                  "pan_base64": agent['pan_base64'] ?? "",
                }
              }),
            )
            .timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['result']?['success'] == true) {
            await DBHelper().deleteAgent(agent['id']);
            synced++;
          }
        }
      } catch (e) {
        debugPrint("❌ Sync failed for ${agent['name']}: $e");
      }
    }

    if (synced > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$synced staff synced successfully!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _stopTokenValidation();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Loginscreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
        title: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: "${loc.welcome} $staffName"),
                TextSpan(
                  text: "\n${loc.unitName} : $unitName",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle,
                      size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "${loc.unitName} : $unitName",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('English'),
                  Switch(
                    value: Provider.of<LocalizationProvider>(context)
                            .locale
                            .languageCode ==
                        'te',
                    onChanged: (_) =>
                        Provider.of<LocalizationProvider>(context, listen: false)
                            .toggleLocale(),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.blue,
                  ),
                  const Text('తెలుగు'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.officestaffdashboard,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // View Created Staff
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.black),
                title: const Text("View Created Staff",
                    style: TextStyle(color: Colors.black)),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _isOnline ? Colors.grey : Colors.grey.shade400,
                ),
                onTap: _isOnline
                    ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Viewcreatedagents()))
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Cannot view staff offline"),
                            backgroundColor: Colors.orange),
                        );
                      },
              ),
            ),
            const SizedBox(height: 12),

            // Offline Created Staff Button
            Card(
              color: Colors.orange[50],
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.cloud_off, color: Colors.orange),
                title: const Text("Offline Created Staff",
                    style: TextStyle(color: Colors.black87)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.orange),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfflineAgentsScreen()),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Create Staff Button
            Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateAgent()),
                  );
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add),
                label: const Text("Create Staff"),
              ),
            ),

            const Spacer(),

            if (!_isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: const Text(
                  "You are offline. You can still create staff, but viewing list requires internet.",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
