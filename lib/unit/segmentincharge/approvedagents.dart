import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/unitwiseagentsmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUnitUrl =
    'https://salesrep.esanchaya.com/api/agents_info_based_on_the_unit';

class approvedagents extends StatefulWidget {
  const approvedagents({super.key});

  @override
  State<approvedagents> createState() => _approvedagentsState();
}

class _approvedagentsState extends State<approvedagents> {
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

  Future<void> fetchAgents(
      String token, String unitName, String sessionId) async {
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
                .where((u) => u.status == 'active') // ✅ Only approved agents
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

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.approvedagents)),
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
                  Text(agent.name ?? localizations.unnamedagent,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Email: ${agent.email ?? localizations.na}"),
                  Text("Phone: ${agent.phone ?? localizations.na}"),
                  Text("Unit: ${agent.unitName ?? localizations.na}"),
                  Text("Role: ${agent.role ?? localizations.na}"),
                  Text("Status: ${agent.status ?? localizations.na}"),
                  Text("ID: ${agent.id ?? localizations.na}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
