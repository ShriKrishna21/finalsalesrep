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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Total Forms Submitted: ${records.length}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final r = records[index];
                        return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.teal.shade300.withOpacity(0.4)),
  ),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal.shade50, Colors.cyan.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon( Icons.person, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              "Family Head: ${r.familyHeadName ?? 'N/A'}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.teal.shade100),
        const SizedBox(height: 8),
        InfoItem(icon: Icons.date_range, label: "Date", value: r.date),
        InfoItem(icon: Icons.location_on, label: "Address", value: r.address),
        InfoItem(icon: Icons.map, label: "City & Pincode", value: "${r.city ?? ''}, ${r.pinCode ?? ''}"),
        InfoItem(icon: Icons.phone_android, label: "Mobile", value: r.mobileNumber),
        InfoItem(icon: Icons.menu_book, label: "Reads Eenadu", value: r.eenaduNewspaper == true ? 'Yes' : 'No'),
        InfoItem(icon: Icons.work, label: "Employed", value: r.employed == true ? 'Yes' : 'No'),
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
  final String? value;

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
        children: [
          Icon(icon, color: Colors.teal.shade600, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
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