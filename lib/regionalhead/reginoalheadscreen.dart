import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/unitwiseusers.dart';
import 'package:finalsalesrep/regionalhead/unitwisescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/regionalhead/createunits.dart';

class Reginoalheadscreen extends StatefulWidget {
  const Reginoalheadscreen({super.key});

  @override
  State<Reginoalheadscreen> createState() => _ReginoalheadscreenState();
}

class _ReginoalheadscreenState extends State<Reginoalheadscreen> {
  String? username;
  String? token;
  List<String> unitNames = [];
  List<Users> allUsers = [];
  bool isLoading = true;
  Timer? _sessionCheckTimer;
  bool _isLoggingOut = false; // Flag to prevent multiple logouts
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchUnits();
    startTokenValidation();
  }

  void startTokenValidation() {
    validateToken();
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => validateToken());
  }

  Future<void> validateToken() async {
    if (_isLoggingOut) return; // Prevent multiple logout attempts

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    if (token == null || token.isEmpty) {
      _forceLogout("Session expired or invalid token.");
      return;
    }

    try {
      final response = await http
          .post(
        Uri.parse('https://salesrep.esanchaya.com/token_validation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": token}
        }),
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Token validation timed out');
      });

      final result = jsonDecode(response.body)['result'];
      if (result == null || result['success'] != true) {
        _forceLogout(
            "Session expired. You may have logged in on another device.");
      }
    } catch (e) {
      _forceLogout(
          "Error validating session: ${e.toString()}. Please log in again.");
    }
  }

  Future<void> _forceLogout(String message) async {
    if (_isLoggingOut) return; // Prevent re-entrant logout
    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('apikey'); // Clear only the token

      // Show SnackBar
      if (_scaffoldMessengerKey.currentState != null) {
        _scaffoldMessengerKey.currentState!.showSnackBar(
          SnackBar(
              content: Text(message), duration: const Duration(seconds: 2)),
        );
      }

      // Delay navigation to allow SnackBar to be visible
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        try {
          Navigator.pushReplacementNamed(context, '/login');
        } catch (e) {
          print('Navigation error: $e');
          // Fallback navigation
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Loginscreen()),
            (route) => false,
          );
        }
      }
    } finally {
      setState(() => _isLoggingOut = false);
    }
  }

  Future<void> loadUserDataAndFetchUnits() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? 'Unknown';
    token = prefs.getString('apikey') ?? '';
    await fetchUnits();
  }

  Future<void> fetchUnits() async {
    final url =
        Uri.parse('https://salesrep.esanchaya.com/api/users_you_created');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": token}
        }),
      ).timeout(const Duration(seconds: 2), onTimeout: () {
        throw TimeoutException('Failed to fetch units');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unitData = unitwiseusers.fromJson(data);
        final users = unitData.result?.users ?? [];

        final units = users
            .map((user) => user.unitName ?? '')
            .where((unit) => unit.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        setState(() {
          allUsers = users;
          unitNames = units;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (_scaffoldMessengerKey.currentState != null) {
          _scaffoldMessengerKey.currentState!.showSnackBar(
            const SnackBar(content: Text('Failed to load units')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (_scaffoldMessengerKey.currentState != null) {
        _scaffoldMessengerKey.currentState!.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        automaticallyImplyLeading: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const agentProfile()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.height / 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white),
              ),
              child: Icon(
                Icons.person,
                size: MediaQuery.of(context).size.height / 16,
              ),
            ),
          ),
        ],
        title: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: localizations.regionalHead,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "\n$username",
                  style: const TextStyle(color: Colors.black),
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
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    "$username",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('English'),
                     Switch(
            value: localeProvider.locale.languageCode == 'te',
            onChanged: (value) {
              if (value) {
                localeProvider.changeLocale('te');   // Switch ON → Telugu
              } else {
                localeProvider.changeLocale('en');   // Switch OFF → English
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.blue,
            activeTrackColor: Colors.green.shade200,
            inactiveTrackColor: Colors.blue.shade200,
          ),
                      const Text('తెలుగు'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: unitNames.isEmpty
                      ? Center(child: Text(localizations.nounitsfound))
                      : ListView.builder(
                          itemCount: unitNames.length,
                          itemBuilder: (context, index) {
                            final unitName = unitNames[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(unitName),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UnitUsersScreen(unitName: unitName),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Createincharge()),
          );
          loadUserDataAndFetchUnits(); // Refresh units after creating a new one
        },
        icon: const Icon(Icons.add),
        label: Text(localizations.createincharge),
      ),
    );
  }
}