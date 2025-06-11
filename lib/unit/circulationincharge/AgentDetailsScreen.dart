import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/modelclasses/ParticularAgentCustomerForms.dart';

class AgentDetailsScreen extends StatefulWidget {
  final User user;

  const AgentDetailsScreen({super.key, required this.user});

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  List<Record> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgentFormDetails();
  }

  Future<void> fetchAgentFormDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');

    if (apiKey == null || widget.user.id == null) {
      print("❌ Missing API key or user ID");
      setState(() => isLoading = false);
      return;
    }

    try {
      final uri = Uri.parse("http://10.100.13.138:8099/api/customer_forms_info");
      print("📤 Sending request to: $uri");
      print("📨 Payload: ${jsonEncode({
        "params": {
          "token": apiKey,
          "user_id": widget.user.id,
        }
      })}");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": apiKey,
            "user_id": widget.user.id,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      print("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final formData = ParticularAgentCustomerForms.fromJson(jsonResponse);

        setState(() {
          records = formData.result?.records ?? [];
          isLoading = false;
        });

        print("✅ Loaded ${records.length} records for agent: ${widget.user.name}");
      } else {
        print("❌ Error: ${response.statusCode} | ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name ?? "Agent Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No forms submitted by this agent."))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${r.date ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Family Head: ${r.familyHeadName ?? 'N/A'}"),
                            Text("Address: ${r.address ?? 'N/A'}"),
                            Text("City: ${r.city ?? ''}, Pincode: ${r.pinCode ?? ''}"),
                            Text("Mobile: ${r.mobileNumber ?? 'N/A'}"),
                            Text("Reads Eenadu: ${r.eenaduNewspaper == true ? 'Yes' : 'No'}"),
                            Text("Employed: ${r.employed == true ? 'Yes' : 'No'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
