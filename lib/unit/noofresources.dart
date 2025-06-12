import 'dart:convert';
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
    final userId = prefs.getInt('id');

    if (apiKey == null || userId == null) {
      print("❌ Missing API key or User ID");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.100.13.138:8099/api/users_you_created"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": apiKey,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = data.result?.users ?? [];
          isLoading = false;
        });

        await prefs.setInt('userCount', users.length);
        print("✅ Response: $jsonResponse");

        for (var user in users) {
          print("User: ${user.name}, ID: ${user.id}, Email: ${user.email}");
        }
      } else {
        print("❌ Fetch error. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API not implemented: $e");
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
      appBar: AppBar(title: const Text("Number of Resources")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No users found"))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgentDetailsScreen(user: user),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.blueAccent),
                                    const SizedBox(width: 8),
                                    Text(
                                      user.name ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                InfoRow(label: "ID", value: user.id?.toString() ?? 'N/A'),
                                InfoRow(label: "Email", value: user.email ?? 'N/A'),
                                InfoRow(label: "Phone", value: user.phone ?? 'N/A'),
                                InfoRow(label: "Role", value: user.role ?? 'N/A'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
