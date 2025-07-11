import 'dart:convert';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/unit/circulationincharge/createstaff.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/common_api_class.dart';

class Circulationinchargescreen extends StatefulWidget {
  const Circulationinchargescreen({super.key});

  @override
  State<Circulationinchargescreen> createState() => _CirculationinchargescreenState();
}

class _CirculationinchargescreenState extends State<Circulationinchargescreen> {
  int agentCount = 0;
  int customerFormCount = 0;
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
      _fetchAgentCount(apiKey, unitName),
      fetchCustomerFormData(apiKey, unitName),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> _fetchAgentCount(String apiKey, String unitName) async {
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
        final users = jsonResponse['result']['users'] as List<dynamic>;

        setState(() {
          agentCount = users.length;
        });

        print("✅ Agent count from Noofresources API: $agentCount");
      } else {
        print("❌ Failed to fetch agent count. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in _fetchAgentCount: $e");
    }
  }

  Future<void> fetchCustomerFormData(String token, String unitName) async {
    try {
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
    } catch (e) {
      print("❌ Customer form fetch error: $e");
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
                  // ✅ Number of Resources
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Noofresources()),
                      );
                      _loadData(); // Refresh on return
                    },
                    child: _buildCard(
                      title: "Number of Resources",
                      rows: [
                        _InfoRow(label: "Agents", value: agentCount.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Subscription Details
                  _buildCard(
                    title: "Subscription Details",
                    rows: [
                      _InfoRow(label: "Houses Visited", value: customerFormCount.toString()),
                      _InfoRow(label: "Eenadu subscription", value: alreadySubscribedCount.toString()),
                      _InfoRow(label: "Willing to change", value: offerAcceptedCount.toString()),
                      _InfoRow(label: "Not Interested", value: offerRejectedCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AssignRouteScreen()),
                        );
                      },
                      child: const Text("Assign Routemap and Target", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const createstaff()),
                        );
                      },
                      child: const Text("Create Officestaff", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: onTap != null ? InkWell(onTap: onTap, child: row) : row,
    );
  }
}
