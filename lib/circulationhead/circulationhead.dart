import 'dart:convert';
import 'package:finalsalesrep/circulationhead/regionheadunits.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/circulationhead/createregionalhead.dart';

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

  // Token Validation Timer
  void startTokenValidationTimer() {
    Future.delayed(const Duration(seconds: 3), () async {
      bool isValid = await validateToken();
      if (!isValid && mounted) {
        logoutUser();
      } else if (mounted) {
        startTokenValidationTimer(); // keep validating
      }
    });
  }

  // Validate Token API
  Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null) return false;

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/token_validation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"params": {"token": token}}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['success'] == true;
    }
    return false;
  }

  // Logout if token is invalid
  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Fetch Regional Heads
  Future<void> fetchRegionalHeads() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

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

        setState(() {
          regionalHeads = nofAgents.result?.users
                  ?.where((user) => user.role == 'region_head')
                  .toList() ??
              [];
          isLoading = false;
        });
      } else {
        print("API Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const agentProfile()),
              );
            },
            child: Icon(
              Icons.person,
              size: MediaQuery.of(context).size.height / 16,
              color: Colors.white,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          Localizations.circulationhead,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : regionalHeads.isEmpty
              ? const Center(
                  child: Text(
                  "No regional heads found",
                  style: TextStyle(color: Colors.black),
                ))
              : ListView.builder(
                  itemCount: regionalHeads.length,
                  itemBuilder: (context, index) {
                    final head = regionalHeads[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
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
                                    "User ID: ${head.email ?? "N/A"}",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ]),
                            Text(
                              "Role: ${head.role ?? "Unknown"}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black),
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
            MaterialPageRoute(
              builder: (context) => const createregionalhead(),
            ),
          );
          fetchRegionalHeads(); // Refresh list
        },
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Create Regional Head"),
      ),
    );
  }
}
