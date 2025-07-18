import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/officestaff.dart/viewcreatedagents.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfficeStaffScreen extends StatefulWidget {
  const OfficeStaffScreen({super.key});

  @override
  State<OfficeStaffScreen> createState() => _OfficeStaffScreenState();
}

class _OfficeStaffScreenState extends State<OfficeStaffScreen> {
  String staffName = '';
  String unitName = '';
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    loadStaffInfo();
    startTokenValidation();
  }

  Future<void> loadStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      staffName = prefs.getString('name') ?? 'Office Staff';
      unitName = prefs.getString('unit') ?? '';
    });
  }

  void startTokenValidation() {
    validateToken(); // First check
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await validateToken();
    });
  }

  Future<void> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null || token.isEmpty) {
      forceLogout("Session expired or invalid token.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/token_validation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      final data = jsonDecode(response.body);
      final result = data['result'];

      if (result == null || result['success'] != true) {
        forceLogout("Session expired. You may have logged in on another device.");
      }
    } catch (e) {
      forceLogout("Error validating session. Please log in again.");
    }
  }

  void forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const agentProfile()),
              );
            },
          )
        ],
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: localizations.office1staff),
              TextSpan(
                text: "\n${localizations.unitName}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(localizations.salesrep),
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
                          localeProvider.toggleLocale();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.officestaffdashboard,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.black),
                title: Text(localizations.viewcreatedagents,
                    style: const TextStyle(color: Colors.black)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Viewcreatedagents()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAgent()));
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add),
                label: Text(localizations.createagent),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
