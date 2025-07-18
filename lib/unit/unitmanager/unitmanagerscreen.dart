import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/unitmanager/agentservice.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:finalsalesrep/unit/unitmanager/profilescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  int alreadySubscribedCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  String unitt = "";
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    fetchAgentCount();
    fetchCustomerFormCount();
    startTokenValidation(); // Start session validation
  }

  void startTokenValidation() {
    validateToken(); // Initial check
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
        body: jsonEncode({"params": {"token": token}}),
      );

      final data = jsonDecode(response.body);
      final result = data['result'];

      if (result == null || result['success'] != true) {
        forceLogout("Session expired. You may have logged in on another device.");
      }
    } catch (e) {
      forceLogout("Error validating session. Please log in again.");
    }
  }

  void forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
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
        unitt = unitName;
      });
    }
  }

  Future<void> _onRefresh() async {
    await fetchAgentCount();
    await fetchCustomerFormCount();
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return null;
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel(); // stop the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

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
            text: Localizations.unitmanager,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(
                text: "  -$unitt",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(Localizations.salesrep),
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
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
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
                    fetchAgentCount();
                  },
                  child: _buildCard(
                    title: Localizations.numberOfResources,
                    gradientColors: [
                      Colors.grey.shade200,
                      Colors.grey.shade400,
                    ],
                    rows: [
                      _InfoRow(
                          label: Localizations.agents,
                          value: agentCount.toString()),
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
                    title: Localizations.viewallcustomerforms,
                    gradientColors: [
                      Colors.grey.shade200,
                      Colors.grey.shade400,
                    ],
                    rows: [
                      _InfoRow(
                          label: Localizations.customerform,
                          value: customerFormCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: Localizations.subscriptionDetails,
                  gradientColors: [
                    Colors.grey.shade200,
                    Colors.grey.shade400,
                  ],
                  rows: [
                    _InfoRow(
                        label: Localizations.houseVisited,
                        value: customerFormCount.toString()),
                    _InfoRow(
                        label: Localizations.eenaduSubscription,
                        value: alreadySubscribedCount.toString()),
                    _InfoRow(
                        label: Localizations.willingToChange,
                        value: offerAcceptedCount.toString()),
                    _InfoRow(
                        label: Localizations.notInterested,
                        value: offerRejectedCount.toString()),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
    this.bold = false,
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
