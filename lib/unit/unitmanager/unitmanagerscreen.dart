import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/unitmanager/agentservice.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:finalsalesrep/unit/unitmanager/profilescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Unitmanagerscreen extends StatefulWidget {
  const Unitmanagerscreen({super.key});

  @override
  State<Unitmanagerscreen> createState() => _UnitmanagerscreenState();
}

class _UnitmanagerscreenState extends State<Unitmanagerscreen> {
  int agentCount = 0;
  int customerFormCount = 0;
  int eenaduSubscriptionCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAgentCount();
    fetchCustomerFormCount();
  }

  Future<void> fetchAgentCount() async {
    final count = await AgentService.fetchAgentCountFromApi();
    setState(() {
      agentCount = count;
    });
  }

  Future<void> fetchCustomerFormCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (token == null || unitName == null) return;

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/api/customer_forms_filtered'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {
          "token": token,
          "from_date": "",
          "to_date": "",
          "unit_name": unitName,
          "agent_name": "",
          "order": "asc",
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final records = data['result']['records'] as List?;

      setState(() {
        customerFormCount = records?.length ?? 0;
        eenaduSubscriptionCount = records
                ?.where((r) => _parseBool(r['eenadu_newspaper']) == true)
                .length ??
            0;
        offerAcceptedCount = records
                ?.where((r) => _parseBool(r['free_offer_15_days']) == true)
                .length ??
            0;
        offerRejectedCount = records
                ?.where((r) => _parseBool(r['free_offer_15_days']) == false)
                .length ??
            0;
      });
    }
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profilescreen()),
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
          )
        ],
        title: RichText(
          text: TextSpan(
            text: "Unit Manager - ",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(
                text: "karimnagar",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Noofresources()),
                    );
                    fetchAgentCount(); // Refresh after return
                  },
                  child: _buildCard(
                    title: "Number of Resources",
                    gradientColors: [
                      Colors.grey.shade200,
                      Colors.grey.shade400,
                    ],
                    rows: [
                      _InfoRow(label: "Agents", value: agentCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Allcustomerforms()),
                    );
                  },
                  child: _buildCard(
                    title: "View All CustomerForms",
                    gradientColors: [
                      Colors.grey.shade200,
                      Colors.grey.shade400,
                    ],
                    rows: [
                      _InfoRow(
                          label: "CustomerForms",
                          value: customerFormCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: "Subscription Details",
                  gradientColors: [
                    Colors.grey.shade200,
                    Colors.grey.shade400,
                  ],
                  rows: [
                    _InfoRow(
                        label: "Houses Visited",
                        value: customerFormCount.toString()),
                    _InfoRow(
                        label: "Eenadu subscription",
                        value: eenaduSubscriptionCount.toString()),
                    _InfoRow(
                        label: "Willing to change",
                        value: offerAcceptedCount.toString()),
                    _InfoRow(
                        label: "Not Interested",
                        value: offerRejectedCount.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: "Route Map",
                  gradientColors: [
                    Colors.grey.shade200,
                    Colors.grey.shade400,
                  ],
                  rows: const [
                    _InfoRow(label: "Routes", value: "0"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Color> gradientColors,
    required List<_InfoRow> rows,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(2, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(children: rows),
          ),
        ],
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
    this.bold = false, // ✅ Default value added to fix error
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 15, color: Colors.black)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
