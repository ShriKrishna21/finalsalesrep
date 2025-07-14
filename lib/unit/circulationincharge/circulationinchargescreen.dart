import 'dart:convert';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/segmentincharge/approveagents.dart';
import 'package:finalsalesrep/unit/segmentincharge/approvedagents.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
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
  State<Circulationinchargescreen> createState() =>
      _CirculationinchargescreenState();
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
        setState(() => agentCount = users.length);
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

        int subscribed = 0, accepted = 0, rejected = 0;

        records?.forEach((r) {
          final bool? newspaper = _parseBool(r['eenadu_newspaper']);
          final bool? offer = _parseBool(r['free_offer_15_days']);

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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${localizations.circulationIncharge} - $namee  $unit"),
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
      drawer: _buildDrawer(localeProvider, localizations),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Noofresources()),
                      );
                      _loadData();
                    },
                    child: _buildCard(
                      title: localizations.numberOfResources,
                      rows: [
                        _InfoRow(
                            label: localizations.agents,
                            value: agentCount.toString())
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Allcustomerforms()));
                    },
                    child: _buildCard(
                      title: localizations.viewallcustomerforms,
                      rows: [
                        _InfoRow(
                            label: localizations.customerforms,
                            value: customerFormCount.toString())
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
                  const SizedBox(height: 30),
                  _buildGridButtons()
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer(
      LocalizationProvider localeProvider, AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              children: [
                const Icon(Icons.account_circle, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(localizations.salesrep,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(localeProvider.locale.languageCode == 'te'
                ? 'తెలుగు'
                : 'English'),
            value: localeProvider.locale.languageCode == 'te',
            onChanged: (_) => localeProvider.toggleLocale(),
            secondary: const Icon(Icons.language),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<_InfoRow> rows}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const Divider(color: Colors.black),
          const SizedBox(height: 8),
          Column(children: rows),
        ],
      ),
    );
  }

  Widget _buildGridButtons() {
    final localizations = AppLocalizations.of(context)!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildBlackWhiteButton(localizations.assignroutemapandtarget, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AssignRouteScreen()));
        }),
        _buildBlackWhiteButton(localizations.createofficestaff, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const createstaff()));
        }),
        _buildBlackWhiteButton(localizations.approvedagents, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const approvedagents()));
        }),
        _buildBlackWhiteButton(localizations.agentswaitingapproval, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const Approveagents()));
        }),
      ],
    );
  }

  Widget _buildBlackWhiteButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
    final row = Row(
      children: [
        Expanded(
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: onTap != null ? InkWell(onTap: onTap, child: row) : row,
    );
  }
}
