import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/agent/coustmerform.dart';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/agent/onedayhistory.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart' show Onedayagent;
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Agentscreen extends StatefulWidget {
  const Agentscreen({super.key});

  @override
  State<Agentscreen> createState() => _AgentscreenState();
}

class _AgentscreenState extends State<Agentscreen> {
  TextEditingController dateController = TextEditingController();
  String agentname = "";
  List<Record> records = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();

  @override
  void initState() {
    super.initState();
    String formattedDate = DateFormat('EEE, MMM d, y').format(DateTime.now());
    dateController.text = formattedDate;
    loadAgentName();
    loadOnedayHistory();
  }

  Future<void> loadAgentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      agentname = prefs.getString('agentname') ?? '';
    });
  }

  Future<void> loadOnedayHistory() async {
    final result = await _onedayagent.fetchOnedayHistory();
    setState(() {
      records = (result['records'] as List<Record>?) ?? [];
      offerAcceptedCount = result['offer_accepted'] ?? 0;
      offerRejectedCount = result['offer_rejected'] ?? 0;
      alreadySubscribedCount = result['already_subscribed'] ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.salesrep),
            Text(
              "${localizations.welcome} $agentname",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const agentProfile()),
              );
            },
          )
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
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(localizations.historyPage),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const historypage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Coustmer()),
          );
        },
        label: Text(
          localizations.customerform,
          style: const TextStyle(color: Colors.black),
        ),
        icon: const Icon(Icons.add_box_outlined, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      dateController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Daily Summary Section
                  Center(child: _buildSectionTitle(localizations.houseVisited)),
                  SizedBox(
                    height: 20,
                  ),
                  _buildInfoRow(localizations.todaysHouseCount, "40"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Onedayhistory()),
                      );
                    },
                    child: _buildInfoRow(
                        localizations.houseVisited, "${records.length}"),
                  ),

                  _buildInfoRow(
                      localizations.todaysTargetLeft, "${40 - records.length}"),

                  const SizedBox(height: 30),

                  // Route Detail Section
                  Center(child: _buildSectionTitle(localizations.myRouteMap)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Onedayhistory()),
                        );
                      },
                      child: _buildBulletPoint("Route 1")),
                  _buildBulletPoint("Route 2"),
                  _buildBulletPoint("Route 3"),

                  const SizedBox(height: 30),

                  // Survey Results Section
                  Center(child: _buildSectionTitle(localizations.reports)),
                  _buildBulletPoint(
                      "${localizations.alreadySubscribed}: $alreadySubscribedCount"),
                  _buildBulletPoint(
                      "${localizations.daysOfferAccepted15}: $offerAcceptedCount"),
                  _buildBulletPoint(
                      "${localizations.daysOfferRejected15}: $offerRejectedCount"),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
