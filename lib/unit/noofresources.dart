import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/agentdetailsscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Noofresources extends StatefulWidget {
  const Noofresources({super.key});

  @override
  State<Noofresources> createState() => _NoofresourcesState();
}

class _NoofresourcesState extends State<Noofresources> {
  List<User> users = [];
  bool isLoading = true;

  Future<void> agentdata() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final unitName = prefs.getString('unit_name'); // ✅ Correct key used

    if (apiKey == null || unitName == null || unitName.isEmpty) {
      print("❌ Missing API key or unit name");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(
                CommonApiClass.agentUnitWise), // ✅ API for unit-based agents
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "token": apiKey,
                "unit_name": unitName,
              }
            }),
          )
          .timeout(const Duration(seconds: 20));

      print("📤 Request sent to: ${CommonApiClass.agentUnitWise}");
      print("📥 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = data.result?.users ?? [];
          isLoading = false;
        });

        await prefs.setInt('userCount', users.length);
        print("✅ Total agents fetched: ${users.length}");
      } else {
        print("❌ Error fetching agents. Status: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception during API call: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    agentdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Number of Resources"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : users.isEmpty
              ? const Center(
                  child: Text("No users found", style: TextStyle(fontSize: 16)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Total Agents: ${users.length}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AgentDetailsScreen(user: user),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person,
                                            color: Colors.black54),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            user.name ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(color: Colors.grey),
                                    InfoRow(
                                        label: "ID",
                                        value: user.id?.toString() ?? 'N/A'),
                                    InfoRow(
                                        label: "Email",
                                        value: user.email ?? 'N/A'),
                                    InfoRow(
                                        label: "Phone",
                                        value: user.phone ?? 'N/A'),
                                    InfoRow(
                                        label: "Role",
                                        value: user.role ?? 'N/A'),
                                    InfoRow(
                                        label: "Unit",
                                        value: user.unitName ?? 'N/A'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.black87)),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
