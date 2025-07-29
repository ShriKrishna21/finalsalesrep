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
  Timer? tokenTimer;

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchUnits();
    startTokenValidation();
  }

  @override
  void dispose() {
    tokenTimer?.cancel();
    super.dispose();
  }

  Future<void> startTokenValidation() async {
    tokenTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      validateToken();
    });
  }

  Future<void> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('apikey') ?? '';

    if (currentToken.isEmpty) {
      print("No token found. Skipping validation.");
      return;
    }

    final url =
        Uri.parse('https://salesrep.esanchaya.com/api/token_validation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": currentToken}
        }),
      );

      print("Token validation response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != true) {
          print("Invalid token, triggering logout.");
          logoutUser();
        }
      } else {
        print("Token validation failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Token validation error: $e");
    }
  }

  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
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
      );

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unitData = unitwiseusers.fromJson(data);
        final users = unitData.result?.users ?? [];

        print("Total users: ${users.length}");
        for (var user in users) {
          print("User: ${user.name}, Unit: ${user.unitName}");
        }

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
        print("Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Fetch units error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
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
            textAlign: TextAlign.center, // 👈 Add this line
            text: TextSpan(
              text: localizations.regionalHead,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Ensure a visible color is set here
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Createincharge()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(localizations.createincharge),
      ),
    );
  }
}
