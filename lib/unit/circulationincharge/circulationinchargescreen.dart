import 'dart:convert';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:finalsalesrep/unit/circulationincharge/circculationinchargeprodfile.dart';
import 'package:finalsalesrep/unit/circulationincharge/createstaff.dart';
import 'package:finalsalesrep/unit/circulationincharge/staffofunit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';

class Circulationinchargescreen extends StatefulWidget {
  const Circulationinchargescreen({super.key});

  @override
  State<Circulationinchargescreen> createState() => _CirculationinchargescreenState();
}

class _CirculationinchargescreenState extends State<Circulationinchargescreen> {
  int agentCount = 0;
  int houseVisited = 0;
  bool isLoading = false;
  String namee = "User";
  String unit = "Unit";

  @override
  void initState() {
    super.initState();
    fetchAgentCount();
  }

  Future<void> fetchAgentCount() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('apikey') ?? '';

      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/users_you_created'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey}
        }),
      );

      if (response.statusCode == 200) {
        final data = NofAgents.fromJson(json.decode(response.body));
        setState(() {
          agentCount = data.result?.users?.length ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load agents");
      }
    } catch (e) {
      print("Error fetching agent count: $e");
      setState(() => isLoading = false);
    }
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
        title: Text("${Localizations.circulationIncharge} - $namee $unit"),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const circulationinchargeprofile()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    Localizations.salesrep,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.black),
              title: const Text("Switch Language", style: TextStyle(color: Colors.black)),
              onTap: () => localeProvider.toggleLocale(),
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
                        label: "Staff",
                        value: agentCount.toString(),
                        bold: true,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const Staffofunit()));
                        },
                      ),
                      _InfoRow(
                        label: "No of agents",
                        value: agentCount.toString(),
                        bold: true,
                        
                        
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: localeProvider.locale.languageCode == "en"
                        ? "Subscription Details"
                        : Localizations.subscriptionDetails,
                    rows: [
                      _InfoRow(label: Localizations.housesCount, value: "0", bold: true),
                      _InfoRow(label: Localizations.housesVisited, value: houseVisited.toString()),
                      _InfoRow(label: Localizations.eenaduSubscription, value: "0"),
                      _InfoRow(label: Localizations.willingToChange, value: "0"),
                      _InfoRow(label: Localizations.notInterested, value: "0"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: "Assign Route Map and Target",
                    rows: [
                      _InfoRow(
                        label: "Routes",
                        value: "0",
                        onTap: () {
                          print("Tapped on Routes");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Assigntargetscreen()));
                      },
                      child: const Text(
                        "Assign Now",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const createstaff()));
                      },
                      child: const Text(
                        "Create User",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                child: Text("$label:",
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black))),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
