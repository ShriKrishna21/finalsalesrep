import 'dart:convert';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/unit/createagent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';

class Circulationinchargescreen extends StatefulWidget {
  const Circulationinchargescreen({super.key});

  @override
  State<Circulationinchargescreen> createState() =>
      _CirculationinchargescreenState();
}

class _CirculationinchargescreenState extends State<Circulationinchargescreen> {
  int agentCount = 0;
  bool isLoading = true;
  String namee = "";
  String unit = "";

  Future<void> agentdata() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final userId = prefs.getInt('id');
    final name = prefs.getString('name');
    final unitt = prefs.getString('unit');
    setState(() {
      namee = name!;
      unit = unitt!;
    });

    if (apiKey == null || userId == null) {
      print("❌ Missing API key or User ID");
      setState(() {
        isLoading = false;
        agentCount = 0;
      });
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(CommonApiClass.Circulationinchargescreen),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "token": apiKey,
              }
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);
        final users = data.result?.users ?? [];

        setState(() {
          agentCount = users.length;
          isLoading = false;
        });

        print("✅ Agent count fetched: $agentCount");
      } else {
        print("❌ Failed to fetch agents. Status code: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception during fetch: $e");
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
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black, // Black app bar
        foregroundColor: Colors.white, // White icons
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => agentProfile(),
                  ));
            },
            child: Container(
              width: MediaQuery.of(context).size.height / 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.white, // White border
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.person,
                size: MediaQuery.of(context).size.height / 16,
                color: Colors.white, // White icon
              ),
            ),
          )
        ],
        title: RichText(
          text: TextSpan(
            text: "Circulation Incharge - ",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text
            ),
            children: <TextSpan>[
              TextSpan(
                text: "$namee  ",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
              TextSpan(
                text: "$unit",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Noofresources()),
                );
              },
              child: _buildSimpleCard(
                title: "Number of Resources",
                rows: [
                  _InfoRow(
                      label: "Agents",
                      value: isLoading ? "..." : agentCount.toString()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSimpleCard(
              title: "Subscription Details",
              rows: const [
                _InfoRow(label: "Houses Count", value: "0", bold: true),
                _InfoRow(label: "Houses Visited", value: "0"),
                _InfoRow(label: "Eenadu Subscription", value: "0"),
                _InfoRow(label: "Willing to Change", value: "0"),
                _InfoRow(label: "Not Interested", value: "0"),
              ],
            ),
            const SizedBox(height: 20),
            _buildSimpleCard(
              title: "Route Map",
              rows: const [
                _InfoRow(label: "Routes", value: "0"),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18), // Rounded corners
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => createagent(),
                      ));
                },
                child: const Text(
                  "Create User",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white), // White text
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white, // White background for the card
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black, // Black text
              ),
            ),
            const SizedBox(height: 8),
            Column(children: rows),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black), // Black text
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: Colors.black, // Black text
            ),
          ),
        ],
      ),
    );
  }
}
