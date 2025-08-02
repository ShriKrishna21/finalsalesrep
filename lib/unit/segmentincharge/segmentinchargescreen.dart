import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/unitmanager/agentservice.dart';

class Segmentinchargescreen extends StatefulWidget {
  const Segmentinchargescreen({super.key});

  @override
  State<Segmentinchargescreen> createState() => _SegmentinchargescreenState();
}

class _SegmentinchargescreenState extends State<Segmentinchargescreen> {
  String userName = '';
  String unitt = '';
  Timer? _sessionCheckTimer;

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
    startTokenValidation();
  }

  void startTokenValidation() {
    validateToken(); // initial check
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await validateToken();
    });
  }

  Future<void> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null || token.isEmpty) {
      forceLogout("Session expired or invalid token.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/token_validation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      final data = jsonDecode(response.body);
      final result = data['result'];

      if (result == null || result['success'] != true) {
        forceLogout(
            "Session expired. You may have logged in on another device.");
      }
    } catch (e) {
      forceLogout("Error validating session. Please log in again.");
    }
  }

  void forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
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

  Future<void> _handleRefresh() async {
    await _loadUserName();
    await fetchAgentCount();
    await fetchCustomerFormCount();
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
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
            Center(
              child: Text(localizations.segmentincharge,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Center(
                child: Text(localizations.segmentincharge,
                    style: const TextStyle(fontSize: 14))),
            Center(child: Text(unitt, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(localizations.segmentincharge),
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('English'),
                      Switch(
                        value: localeProvider.locale.languageCode == 'te',
                        onChanged: (value) {
                          localeProvider.toggleLocale();
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.blue,
                        activeTrackColor: Colors.green.shade200,
                        inactiveTrackColor: Colors.blue.shade200,
                      ),
                      const Text('తెలుగు'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Noofresources()),
                    );
                  },
                  child: _buildCard(
                    title: localizations.numberOfResources,
                    rows: [
                      _InfoRow(label: "Staff", value: agentCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const Allcustomerforms()),
                    );
                  },
                  child: _buildCard(
                    title: localizations.viewallcustomerforms,
                    rows: [
                      _InfoRow(
                          label: localizations.customerform,
                          value: customerFormCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
              ],
            ),
          ),
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
