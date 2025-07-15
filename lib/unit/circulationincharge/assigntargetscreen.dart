import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignRouteScreen extends StatefulWidget {
  const AssignRouteScreen({super.key});

  @override
  State<AssignRouteScreen> createState() => _AssignRouteScreenState();
}

class _AssignRouteScreenState extends State<AssignRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _routeMapController = TextEditingController();
  final TextEditingController _assignTargetController = TextEditingController();

  List<User> users = [];
  User? selectedAgent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    agentdata();
  }

  Future<void> agentdata() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (apiKey == null || unitName == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(CommonApiClass.agentUnitWise),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": apiKey,
            "unit_name": unitName,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = data.result?.users ?? [];
          selectedAgent = users.isNotEmpty ? users.first : null;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Future<bool> assignRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null || selectedAgent == null) return false;

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/api/For_root_map_asin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {
          "token": token,
          "agent_id": selectedAgent!.id.toString(),
          "root_map": _routeMapController.text.trim(),
        }
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> assignTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || sessionId == null || selectedAgent == null)
      return false;

    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/update/target"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "params": {
          "user_id": selectedAgent!.id.toString(),
          "token": token,
          "target": int.tryParse(_assignTargetController.text.trim()) ?? 0,
        }
      }),
    );

    final result = jsonDecode(response.body);
    return result["result"]?["success"] == "True";
  }

  void _onSubmit() async {
    final localizations = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate() && selectedAgent != null) {
      final routeSuccess = await assignRoute();
      final targetSuccess = await assignTarget();

      if (routeSuccess && targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations.routeandtargetassignedsuccessfully)),
        );
        Navigator.of(context).pop();
      } else if (!routeSuccess && !targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bothassignmentsfailed)),
        );
      } else if (!routeSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.routeassignmentfailed)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.targetassignmentfailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.assignroutetarget)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: agentdata,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<User>(
                        decoration: InputDecoration(
                          labelText: localizations.selectagent,
                          border: const OutlineInputBorder(),
                        ),
                        value: selectedAgent,
                        items: users.map((User user) {
                          return DropdownMenuItem<User>(
                            value: user,
                            child: Text('${user.name} (ID: ${user.id})'),
                          );
                        }).toList(),
                        onChanged: (User? newValue) {
                          setState(() {
                            selectedAgent = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? localizations.selectagent : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _routeMapController,
                        decoration: InputDecoration(
                          labelText: localizations.routeMap,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? localizations.enterroutemap
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _assignTargetController,
                        decoration: InputDecoration(
                          labelText: localizations.assigntarget,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? localizations.entertarget
                            : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _onSubmit,
                        child: Text(localizations.submit),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
