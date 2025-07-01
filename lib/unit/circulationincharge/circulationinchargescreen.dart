import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/unit/createagent.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/modelclasses/unitwiseforms.dart';

class Circulationinchargescreen extends StatefulWidget {
  const Circulationinchargescreen({super.key});

  @override
  State<Circulationinchargescreen> createState() => _CirculationinchargescreenState();
}

class _CirculationinchargescreenState extends State<Circulationinchargescreen> {
  int agentCount = 0;
  int houseVisited = 0;
  bool isLoading = true;
  String namee = "";
  String unit = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final name = prefs.getString('name') ?? "User";
    final unitName = prefs.getString('unit') ?? "Unit";

    setState(() {
      namee = name;
      unit = unitName;
    });

    if (apiKey == null) return;

    await Future.wait([
      _fetchAgentCount(apiKey),
      _fetchUnitWiseForms(apiKey, unitName),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> _fetchAgentCount(String apiKey) async {
    try {
      final resp = await http.post(
        Uri.parse(CommonApiClass.Circulationinchargescreen),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"params": {"token": apiKey}}),
      );

      if (resp.statusCode == 200) {
        final data = NofAgents.fromJson(jsonDecode(resp.body));
        final list = data.result?.users ?? [];
        setState(() => agentCount = list.length);
      }
    } catch (e) {
      print("❌ Agent count error: $e");
    }
  }

  Future<void> _fetchUnitWiseForms(String apiKey, String unitName) async {
    try {
      final resp = await http.post(
        Uri.parse(CommonApiClass.agentUnitWiseForms),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": apiKey,
            "unit_name": unitName,
          }
        }),
      );

      if (resp.statusCode == 200) {
        final data = UnitWiseFormsResponse.fromJson(jsonDecode(resp.body));
        final count = data.result?.customerforms?.length ?? 0;
        setState(() => houseVisited = count);
      }
    } catch (e) {
      print("❌ UnitWiseForms error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("Circulation Incharge - $namee  $unit"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => agentProfile()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Noofresources()),
                    ),
                    child: _buildCard(
                      title: "Number of Resources",
                      rows: [
                        _InfoRow(label: "Agents", value: agentCount.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: "Subscription Details",
                    rows: [
                      _InfoRow(label: "Houses Count", value: "0", bold: true),
                      _InfoRow(label: "Houses Visited", value: houseVisited.toString()),
                      _InfoRow(label: "Eenadu Subscription", value: "0"),
                      _InfoRow(label: "Willing to Change", value: "0"),
                      _InfoRow(label: "Not Interested", value: "0"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: "Route Map",
                    rows: const [ _InfoRow(label: "Routes", value: "0") ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const createagent()),
                      ),
                      child: const Text(
                        "Create User",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required List<_InfoRow> rows}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(children: rows),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
