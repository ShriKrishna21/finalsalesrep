import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Agentaddrouite extends StatefulWidget {
  final int agentId;
  final String token;

  const Agentaddrouite({
    super.key,
    required this.agentId,
    required this.token,
  });

  @override
  State<Agentaddrouite> createState() => _AgentaddrouiteState();
}

class _AgentaddrouiteState extends State<Agentaddrouite> {
  final TextEditingController _assignTargetController = TextEditingController();
  List<Map<String, TextEditingController>> fromToControllers = [
    {
      'from': TextEditingController(),
      'to': TextEditingController(),
    },
  ];

  @override
  void dispose() {
    _assignTargetController.dispose();
    for (var controllers in fromToControllers) {
      controllers['from']!.dispose();
      controllers['to']!.dispose();
    }
    super.dispose();
  }

  Future<bool> assignRoute() async {
    final fromToList = fromToControllers
        .where((pair) =>
            pair['from']!.text.trim().isNotEmpty &&
            pair['to']!.text.trim().isNotEmpty)
        .map((pair) => {
              "from_location": pair['from']!.text.trim(),
              "to_location": pair['to']!.text.trim(),
            })
        .toList();

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/api/For_root_map_asin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {
          "token": widget.token,
          "agent_id": widget.agentId.toString(),
          "from_to_list": fromToList,
        }
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("Failed to assign route: ${response.statusCode}");
      return false;
    }

    final result = jsonDecode(response.body);
    return result["result"]?["success"] == true;
  }

  Future<bool> assignTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');

    if (sessionId == null) {
      debugPrint("Session ID not found");
      return false;
    }

    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/update/target"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "params": {
          "user_id": widget.agentId.toString(),
          "token": widget.token,
          "target": int.tryParse(_assignTargetController.text.trim()) ?? 0,
        }
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("Failed to assign target: ${response.statusCode}");
      return false;
    }

    final result = jsonDecode(response.body);
    return result["result"]?["success"] == true;
  }

  void addFromToControllers() {
    setState(() {
      fromToControllers.add({
        'from': TextEditingController(),
        'to': TextEditingController(),
      });
    });
  }

  Widget _buildFromToFields(
      Map<String, TextEditingController> controllers, int index) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controllers['from'],
              decoration: const InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controllers['to'],
              decoration: const InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        foregroundColor: Colors.white,
        title: const Text("Assign Route & Target"),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1.2,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assign Target",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assignTargetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Target",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Assign Route",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: fromToControllers
                  .asMap()
                  .entries
                  .map((entry) => _buildFromToFields(entry.value, entry.key))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: addFromToControllers,
                icon: const Icon(Icons.add),
                label: const Text("Add More"),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final routeSuccess = await assignRoute();
                  final targetSuccess = await assignTarget();
      
                  final success = routeSuccess && targetSuccess;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? "Assigned Successfully"
                          : "Assignment Failed"),
                    ),
                  );
      
                  Navigator.pop(context, success);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text("Assign"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}