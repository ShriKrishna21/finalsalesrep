import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/segmentincharge/approveagents.dart';
import 'package:finalsalesrep/unit/segmentincharge/approvedagents.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:finalsalesrep/unit/circulationincharge/createstaff.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    startTokenValidation();
    _loadData();
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  void startTokenValidation() {
    validateToken();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
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
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Padding(
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
                              label: "Staff Name", value: agentCount.toString())
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
            ),
    );
  }

  Widget _buildDrawer(
      LocalizationProvider localeProvider, AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              children: [
                // Image.asset('assets/logo.png'),
                const Icon(Icons.account_circle, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text("${localizations.circulationIncharge}    ",
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('English'),
                Switch(
                  value: localeProvider.locale.languageCode == 'te',
                  onChanged: (value) => localeProvider.toggleLocale(),
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.blue,
                  activeTrackColor: Colors.green.shade200,
                  inactiveTrackColor: Colors.blue.shade200,
                ),
                const Text('తెలుగు'),
              ],
            ),
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
        _buildBlackWhiteButton("Approved Staff", () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const approvedagents()));
        }),
        _buildBlackWhiteButton("Staff Waiting  For Approval", () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ApproveAgents()));
        }),
        _buildBlackWhiteButton("Staff working route ", () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ApproveAgents()));
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
