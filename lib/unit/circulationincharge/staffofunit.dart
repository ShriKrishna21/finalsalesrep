import 'dart:convert';

import 'package:finalsalesrep/modelclasses/noofagents.dart' show NofAgents, User;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- MAIN SCREEN ------------------

class Staffofunit extends StatefulWidget {
  const Staffofunit({super.key});

  @override
  State<Staffofunit> createState() => _StaffofunitState();
}

class _StaffofunitState extends State<Staffofunit> {
  List<User> userList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('apikey') ?? '';

      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/users_you_created'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey}
        }),
      );

      if (response.statusCode == 200) {
        final data = NofAgents.fromJson(json.decode(response.body));
        setState(() {
          userList = data.result?.users ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users You Created'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
     body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : userList.isEmpty
        ? const Center(child: Text('No users found.'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  "Total Users: ${userList.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: userList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'Unnamed',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Divider(height: 20, color: Colors.black12),

                            // Group 1: Contact Info
                            const Text(
                              "Contact Info",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            InfoRow(label: 'Phone', value: user.phone ?? '-'),
                            InfoRow(label: 'Email', value: user.email ?? '-'),
                            InfoRow(label: 'Login ID', value: user.login ?? '-'),

                            const SizedBox(height: 12),

                            // Group 2: Identity
                            const Text(
                              "Identity",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            InfoRow(label: 'PAN', value: user.panNumber ?? '-'),
                            InfoRow(label: 'Aadhar', value: user.aadharNumber ?? '-'),

                            const SizedBox(height: 12),

                            // Group 3: Organizational Info
                            const Text(
                              "Organization",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            InfoRow(label: 'Role', value: user.role ?? '-'),
                            InfoRow(label: 'Unit', value: user.unitName ?? '-'),
                            InfoRow(label: 'State', value: user.state ?? '-'),
                            InfoRow(label: 'Status', value: user.status ?? '-'),
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
