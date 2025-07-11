import 'dart:convert';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:finalsalesrep/unit/circulationincharge/staffofunit.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/unit/circulationincharge/createstaff.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/modelclasses/unitwiseforms.dart';

class Circulationinchargescreen extends StatefulWidget {
  const Circulationinchargescreen({super.key});

  @override
  State<Circulationinchargescreen> createState() =>
      _CirculationinchargescreenState();
}

class _CirculationinchargescreenState extends State<Circulationinchargescreen> {
  int agentCount = 0;
  int staffCount = 0;
  int houseVisited = 0;
  int alreadySubscribedCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
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
      _fetchAgentAndStaffCount(apiKey),
      _fetchUnitWiseForms(apiKey, unitName),
      fetchSubscriptionDetails(),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> _fetchAgentAndStaffCount(String apiKey) async {
    try {
      final resp = await http.post(
        Uri.parse(CommonApiClass.Circulationinchargescreen),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey}
        }),
      );

      if (resp.statusCode == 200) {
        final data = NofAgents.fromJson(jsonDecode(resp.body));
        final users = data.result?.users ?? [];

        int agents = 0;
        int staff = 0;

        for (var user in users) {
          final role = user.role?.toLowerCase();
          if (role == 'agent') {
            agents++;
          } else {
            staff++;
          }
        }

        setState(() {
          agentCount = agents;
          staffCount = staff;
        });
      }
    } catch (e) {
      print("❌ Agent/Staff count error: $e");
    }
  }

  Future<void> _fetchUnitWiseForms(String apiKey, String unitName) async {
    try {
      final resp = await http.post(
        Uri.parse(CommonApiClass.agentUnitWise),
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

  Future<void> fetchSubscriptionDetails() async {
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
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${Localizations.circulationIncharge} - $namee  $unit"),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const agentProfile()),
            ),
          ),
        ],
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
              leading: const Icon(Icons.language),
              title: const Text("Switch Language"),
              onTap: () {
                localeProvider.toggleLocale();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(Localizations.historyPage),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Historypage()),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildCard(
                    title: "Unit Summary",
                    rows: [
                      _InfoRow(
                        label: "Total Staff in Unit",
                        value: agentCount.toString(),
                        bold: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Staffofunit(),
                            ),
                          );
                        },
                      ),
                      _InfoRow(
                        label: "Total Sgents in Unit",
                        value: staffCount.toString(),
                        bold: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Noofresources(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ Replaced Number of Resources Container
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Noofresources()),
                      );
                    },
                    child: _buildCard(
                      title: Localizations.numberOfResources,
                      rows: [
                        _InfoRow(
                          label: Localizations.agents,
                          value: agentCount.toString(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Replaced Subscription Details Container
                  _buildCard(
                    title: Localizations.subscriptionDetails,
                    rows: [
                      _InfoRow(
                          label: Localizations.housesVisited,
                          value: houseVisited.toString()),
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
                  _buildCard(
                    title: "Assign Route Map and Target",
                    rows: const [
                      _InfoRow(label: "Routes", value: "0"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AssignRouteScreen()),
                        );
                      },
                      child: const Text(
                        "Assign Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const createstaff()),
                        );
                      },
                      child: const Text(
                        "Create User",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      children: [
        Expanded(
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style:
              TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: onTap != null ? InkWell(onTap: onTap, child: row) : row,
    );
  }
}
