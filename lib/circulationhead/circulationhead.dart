import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/circulationhead/createregionalhead.dart';
import 'package:finalsalesrep/circulationhead/regionheadunits.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';

class CirculationHead extends StatefulWidget {
  const CirculationHead({super.key});

  @override
  State<CirculationHead> createState() => _CirculationHeadState();
}

class _CirculationHeadState extends State<CirculationHead> {
  List<User> regionalHeads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRegionalHeads();
    startTokenValidationTimer();
  }

  void startTokenValidationTimer() {
    Future.delayed(const Duration(seconds: 3), () async {
      bool isValid = await validateToken();
      if (!isValid && mounted) {
        logoutUser();
      } else if (mounted) {
        startTokenValidationTimer(); // Recursively repeat
      }
    });
  }

  Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/token_validation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {"token": token}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['success'] == true;
    }
    return false;
  }

  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> fetchRegionalHeads() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null) {
      print("No token found.");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(CommonApiClass.noOfAgents),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final nofAgents = NofAgents.fromJson(jsonMap);

        final filtered = nofAgents.result?.users
            ?.where((user) => user.role == 'region_head')
            .toList();

        setState(() {
          regionalHeads = filtered ?? [];
          isLoading = false;
        });
      } else {
        print("API Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        centerTitle: true,
        title: Text(
          localizer.circulationhead,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person,
                size: MediaQuery.of(context).size.height / 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const agentProfile()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(localizer.circulationhead),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : regionalHeads.isEmpty
              ? const Center(
                  child: Text(
                    "No regional heads found",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : ListView.builder(
                  itemCount: regionalHeads.length,
                  itemBuilder: (context, index) {
                    final head = regionalHeads[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Regionheadunits(userId: head.id ?? 0),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    head.name ?? "No Name",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Email: ${head.email ?? "N/A"}",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ]),
                            Text(
                              "Role: ${head.role ?? "Unknown"}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const createregionalhead()),
          );
          fetchRegionalHeads(); // Refresh list
        },
        icon: const Icon(Icons.add),
        label: Text(Localizations.createregionalhead),
      ),
    );
  }
}
