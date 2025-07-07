import 'package:finalsalesrep/modelclasses/approveagent.dart';
import 'package:finalsalesrep/modelclasses/unitwiseagentsmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUnitUrl = 'https://salesrep.esanchaya.com/api/agents_info_based_on_the_unit';

class Approveagents extends StatefulWidget {
  const Approveagents({super.key});

  @override
  State<Approveagents> createState() => _ApproveagentsState();
}

class _ApproveagentsState extends State<Approveagents> {
    List<Users> agents = [];
    bool loading = true;
    String? error;

    @override
    void initState() {
      super.initState();
      _loadDataAndFetchAgents();
    }

    Future<void> _loadDataAndFetchAgents() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey');
      final unitName = prefs.getString('unit');
      final sessionId = prefs.getString('session_id');

      if (token == null || unitName == null || sessionId == null) {
        setState(() {
          error = 'Missing token, unit, or session ID in SharedPreferences';
          loading = false;
        });
        return;
      }

      await fetchAgents(token, unitName, sessionId);
    }

    Future<void> fetchAgents(String token, String unitName, String sessionId) async {
      final body = json.encode({
        "params": {
          "token": token,
          "unit_name": unitName,
        }
      });

      try {
        final response = await http.post(
          Uri.parse(apiUnitUrl),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'FlutterApp/1.0',
            'Cookie': 'session_id=$sessionId',
          },
          body: body,
        );

        print("🔐 SESSION ID USED: $sessionId");

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final unitData = unitwiseagent.fromJson(decoded);

          if (unitData.result?.users != null) {
            setState(() {
              agents = unitData.result!.users!
                  .where((u) => u.status == 'un_activ')
                  .toList();
              loading = false;
            });
          } else {
            setState(() {
              error = 'No agents found.';
              loading = false;
            });
          }
        } else {
          setState(() {
            error = 'Server error: ${response.statusCode}';
            loading = false;
          });
        }
      } catch (e) {
        setState(() {
          error = 'Network error: $e';
          loading = false;
        });
      }
    }

  Future<void> approveAgent(int userId) async {
    const String apiUrl = "https://salesrep.esanchaya.com/update/status";
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing API token or session ID")),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      "params": {
        "user_id": userId.toString(),
        "token": token,
        "status": "active",
      }
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FlutterApp/1.0',
          'Cookie': 'session_id=$sessionId',
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Approve status code: ${response.statusCode}");
      print("📦 Approve response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("📩 Decoded JSON: $jsonResponse");

        final ApproveAgent agentResponse = ApproveAgent.fromJson(jsonResponse);

        if (agentResponse.result != null && agentResponse.result!.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Agent approved successfully")),
          );
          _loadDataAndFetchAgents();
        } else {
          final errorMsg = agentResponse.result?.message ?? 'Unknown error or empty response';
          print("❌ Approval failed: $errorMsg");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: $errorMsg")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❗ Exception occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Approve Agents')),
      body: ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agent = agents[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agent.name ?? 'Unnamed Agent',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Email: ${agent.email ?? 'N/A'}"),
                  Text("Phone: ${agent.phone ?? 'N/A'}"),
                  Text("Unit: ${agent.unitName ?? 'N/A'}"),
                  Text("Role: ${agent.role ?? 'N/A'}"),
                  Text("Status: ${agent.status ?? 'N/A'}"),
                  Text("id: ${agent.id ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: () async {
                        print("🟢 Approving agent ID: ${agent.id}");
                        await approveAgent(agent.id ?? 0);
                      },
                      child: const Text("Approve",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
