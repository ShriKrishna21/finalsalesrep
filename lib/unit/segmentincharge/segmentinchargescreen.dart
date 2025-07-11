import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/unit/segmentincharge/approvedagents.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/segmentincharge/approveagents.dart';
import 'package:finalsalesrep/unit/unitmanager/agentservice.dart';

class Segmentinchargescreen extends StatefulWidget {
  const Segmentinchargescreen({super.key});

  @override
  State<Segmentinchargescreen> createState() => _SegmentinchargescreenState();
}

class _SegmentinchargescreenState extends State<Segmentinchargescreen> {
  String userName = '';
  String unitt = '';

  int agentCount = 0;
  int customerFormCount = 0;
  int alreadySubscribedCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchAgentCount();
    fetchCustomerFormCount();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Unknown';
      unitt = prefs.getString('unit') ?? 'Unknown';
    });
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

      int subscribed = 0;
      int accepted = 0;
      int rejected = 0;

      records?.forEach((r) {
        bool? newspaper = _parseBool(r['eenadu_newspaper']);
        bool? offer = _parseBool(r['free_offer_15_days']);

        if (newspaper == true) {
          subscribed++;
        } else {
          if (offer == true) {
            accepted++;
          } else if (offer == false && newspaper == false) {
            rejected++;
          }
        }
      });

      setState(() {
        customerFormCount = records?.length ?? 0;
        alreadySubscribedCount = subscribed;
        offerAcceptedCount = accepted;
        offerRejectedCount = rejected;
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
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const agentProfile()),
              );
            },
          )
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.segmentincharge,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(userName, style: const TextStyle(fontSize: 14)),
            Text(unitt, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(localizations.salesrep),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Switch Language"),
              onTap: () {
                localeProvider.toggleLocale();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Noofresources()),
                );
              },
              child: _buildCard(
                title: localizations.numberOfResources,
                rows: [
                  _InfoRow(
                      label: localizations.agents,
                      value: agentCount.toString()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: localizations.subscriptionDetails,
              rows: [
                _InfoRow(
                    label: localizations.housesVisited,
                    value: customerFormCount.toString()),
                _InfoRow(
                    label: localizations.eenaduSubscription,
                    value: alreadySubscribedCount.toString()),
                _InfoRow(
                    label: localizations.willingToChange,
                    value: offerAcceptedCount.toString()),
                _InfoRow(
                    label: localizations.notInterested,
                    value: offerRejectedCount.toString()),
              ],
            ),
            const SizedBox(height: 16),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const approvedagents()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                ),
                child: Text(localizations.approvedagents,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Approveagents()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                ),
                child: Text(localizations.inprogressagents,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
          const SizedBox(height: 8),
          Column(children: rows),
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
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const Text(": "),
          Text(
            value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
