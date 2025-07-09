import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
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
      final uri = Uri.parse(CommonApiClass.AgentDetailsScreen);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "token": apiKey,
                "user_id": widget.user.id,
              }
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final formData = ParticularAgentCustomerForms.fromJson(jsonResponse);

        setState(() {
          records = formData.result?.records ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Error: ${response.statusCode} | ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  String _boolToText(bool? value) {
    if (value == null) return 'N/A';
    return value ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name ?? "Agent Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No forms submitted by this agent."))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Total Forms Submitted: ${records.length}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final r = records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          color: Colors.black),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Family Head: ${r.familyHeadName ?? 'N/A'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(color: Colors.grey),
                                  const SizedBox(height: 8),
                                  InfoItem(
                                    icon: Icons.date_range,
                                    label: "Date",
                                    value: r.date ?? 'N/A',
                                  ),
                                  InfoItem(
                                    icon: Icons.location_on,
                                    label: "Address",
                                    value: r.address ?? 'N/A',
                                  ),
                                  InfoItem(
                                    icon: Icons.map,
                                    label: "City & Pincode",
                                    value:
                                        "${r.city ?? 'N/A'}, ${r.pinCode ?? 'N/A'}",
                                  ),
                                  InfoItem(
                                    icon: Icons.phone_android,
                                    label: "Mobile",
                                    value: r.mobileNumber ?? 'N/A',
                                  ),
                                  InfoItem(
                                    icon: Icons.newspaper,
                                    label: "Reads Any Newspaper",
                                    value: _boolToText(r.readNewspaper),
                                  ),
                                  InfoItem(
                                    icon: Icons.menu_book,
                                    label: "Reads Eenadu",
                                    value: _boolToText(r.eenaduNewspaper),
                                  ),
                                  InfoItem(
                                    icon: Icons.card_giftcard,
                                    label: "15 Days Free Offer",
                                    value: _boolToText(r.freeOffer15Days),
                                  ),
                                  InfoItem(
                                    icon: Icons.work,
                                    label: "Employed",
                                    value: _boolToText(r.employed),
                                  ),
                                ],
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

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value; // was: String?

  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
