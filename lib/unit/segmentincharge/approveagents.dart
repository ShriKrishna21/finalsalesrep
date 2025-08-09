import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/modelclasses/unitwiseagentsmodel.dart';
import 'package:finalsalesrep/modelclasses/approveagent.dart';
import 'package:finalsalesrep/unit/circulationincharge/govtidimages.dart';

const String apiUnitUrl =
    'https://salesrep.esanchaya.com/api/agents_info_based_on_the_unit';
const String apiApproveUrl = 'https://salesrep.esanchaya.com/update/status';

class ApproveAgents extends StatefulWidget {
  const ApproveAgents({Key? key}) : super(key: key);

  @override
  _ApproveAgentsState createState() => _ApproveAgentsState();
}

class _ApproveAgentsState extends State<ApproveAgents> {
  List<Users> agents = [];
  bool loading = true;
  String? error;
  bool approving = false;
  int? approvingUserId;

  @override
  void initState() {
    super.initState();
    _loadDataAndFetchAgents();
  }

  Future<void> _loadDataAndFetchAgents() async {
    setState(() {
      loading = true;
      error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit');
    final sessionId = prefs.getString('session_id');

    if (token == null || unitName == null || sessionId == null) {
      setState(() {
        error =" missingCredentials";
        loading = false;
      });
      return;
    }

    try {
      final resp = await http.post(
        Uri.parse(apiUnitUrl),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: jsonEncode({"params": {"token": token, "unit_name": unitName}}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final listUsers = UnitwiseAgent.fromJson(data).result?.users ?? [];
        setState(() {
          agents =
              listUsers.where((u) => u.status == 'un_activ').toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${resp.statusCode}';
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

  Future<void> _approveAgent(Users agent) async {
    setState(() {
      approving = true;
      approvingUserId = agent.id;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    final resp = await http.post(
      Uri.parse(apiApproveUrl),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "params": {
          "user_id": agent.id.toString(),
          "token": token,
          "status": "active"
        }
      }),
    );

    final msg = (resp.statusCode == 200)
        ? ApproveAgent.fromJson(jsonDecode(resp.body))
                .result
                ?.message ??
            "approveSuccess"
        : 'Server error: ${resp.statusCode}';

    setState(() {
      agents.removeWhere((a) => a.id == agent.id);
      approving = false;
      approvingUserId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text("Approve Staff")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDataAndFetchAgents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: agents.length,
                    itemBuilder: (ctx, i) {
                      final agent = agents[i];
                      final isThisApproving =
                          approving && approvingUserId == agent.id;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.name ?? loc.unnamedagent,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text('📧 ${agent.email ?? loc.na}'),
                              Text('📱 ${agent.phone ?? loc.na}'),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GovtIdImages(
                                              agentId: agent.id ?? 0),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Governamentid",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: isThisApproving
                                        ? null
                                        : () => _approveAgent(agent),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: isThisApproving
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text("approve"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
