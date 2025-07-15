import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/modelclasses/unitwiseagentsmodel.dart';
import 'package:finalsalesrep/modelclasses/approveagent.dart';

const String apiUnitUrl =
    'https://salesrep.esanchaya.com/api/agents_info_based_on_the_unit';
const String apiApproveUrl = 'https://salesrep.esanchaya.com/update/status';

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
        error = 'Missing token, unit, or session ID';
        loading = false;
      });
      return;
    }

    await fetchAgents(token, unitName, sessionId);
  }

  Future<void> fetchAgents(
      String token, String unitName, String sessionId) async {
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUnitUrl),
        headers: headers,
        body: jsonEncode({
          "params": {"token": token, "unit_name": unitName},
        }),
      );

      if (response.statusCode == 200) {
        final unitData = unitwiseagent.fromJson(jsonDecode(response.body));
        setState(() {
          agents = unitData.result?.users
                  ?.where((u) => u.status == 'un_activ')
                  .toList() ??
              [];
          loading = false;
        });
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

  /// Approves the agent and returns a message to display
  Future<String> approveAgent(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || sessionId == null) {
      return "Missing token or session ID";
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    };

    final body = jsonEncode({
      "params": {
        "user_id": userId.toString(),
        "token": token,
        "status": "active"
      },
    });

    try {
      final response = await http.post(
        Uri.parse(apiApproveUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final agentResponse = ApproveAgent.fromJson(jsonDecode(response.body));

        // Debug logs
        print('Approve API response body: ${response.body}');
        print(
            'Parsed success: ${agentResponse.result?.success}, message: ${agentResponse.result?.message}');

        if (agentResponse.result?.success == true) {
          // reload list
          _loadDataAndFetchAgents();
          return agentResponse.result?.message ?? "Agent approved successfully";
        } else {
          return agentResponse.result?.message ??
              "Approval  approved successfully";
        }
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Network error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null)
      return Scaffold(body: Center(child: Text("Error: $error")));

    return Scaffold(
      appBar: AppBar(title: Text(localizations.approveagents)),
      body: ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agent = agents[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agent.name ?? localizations.unnamedagent,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Email: ${agent.email ?? localizations.na}"),
                  Text("Phone: ${agent.phone ?? localizations.na}"),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () async {
                        final message = await approveAgent(agent.id ?? 0);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      child: Text(localizations.approveagents,
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
