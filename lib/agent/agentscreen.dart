import 'dart:async';
import 'dart:convert';
import 'package:finalsalesrep/agent/agentaddrouite.dart';
import 'package:finalsalesrep/agent/edittarget.dart';
import 'package:finalsalesrep/unit/circulationincharge/assigntargetscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/routemap.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/agent/addextrapoint.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/agent/coustmerform.dart';
import 'package:finalsalesrep/agent/historypage.dart';
import 'package:finalsalesrep/agent/onedayhistory.dart';

class Agentscreen extends StatefulWidget {
  const Agentscreen({super.key});

  @override
  State<Agentscreen> createState() => _AgentscreenState();
}

class _AgentscreenState extends State<Agentscreen> {
  TextEditingController dateController = TextEditingController();
  String agentname = "";
  String? target;
  String? routeName;
  List<Record> records = [];
  bool _isLoading = true;
  Timer? _sessionCheckTimer;
  RouteMap? fullRouteMap;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();

  @override
  void initState() {
    super.initState();
    startTokenValidation();
    dateController.text = DateFormat('EEE, MMM d, y').format(DateTime.now());
    loadAgentData();
    refreshData();
  }

  void startTokenValidation() {
    validateToken();
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => validateToken());
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
      final result = jsonDecode(response.body)['result'];
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
        (route) => false);
  }

  Future<void> refreshData() async {
    setState(() => _isLoading = true);
    await loadOnedayHistory();
    await fetchFullRouteMap();
    await fetchTarget();
    setState(() => _isLoading = false);
  }

  Future<void> fetchFullRouteMap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/user_root_maps_by_stage"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {"user_id": userId, "token": token}
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routeMap = RouteMap.fromJson(data);

        final today = DateTime.now();
        final todayOnlyRoutes = routeMap.result?.assigned?.where((assigned) {
          final routeDate = DateTime.tryParse(assigned.date ?? '');
          return routeDate != null &&
              routeDate.year == today.year &&
              routeDate.month == today.month &&
              routeDate.day == today.day;
        }).toList();

        Assigned? latestRoute;
        if (todayOnlyRoutes != null && todayOnlyRoutes.isNotEmpty) {
          todayOnlyRoutes.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          latestRoute = todayOnlyRoutes.first;
        }

        setState(() {
          fullRouteMap = routeMap;
          fullRouteMap?.result?.assigned =
              latestRoute != null ? [latestRoute] : [];
        });
      } else {
        debugPrint("Failed to fetch full route map: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching full route map: $e");
    }
  }

  Future<void> loadAgentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        agentname = prefs.getString('agentname') ?? '';
      });
      await fetchTarget();
    } catch (e) {
      debugPrint("Error loading agent data: $e");
    }
  }
Future<void> fetchTarget() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('apikey');
  final userId = prefs.getInt('id');

  if (token == null || userId == null) {
    debugPrint("Missing token or user ID");
    setState(() {
      target = prefs.getString('target') ?? "0";
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/update/target"),
      headers: {
        "Content-Type": "application/json",
        "Cookie": "session_id=${prefs.getString('session_id')}",
      },
      body: jsonEncode({
        "params": {"user_id": userId, "token": token}
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result["result"]?["success"] == true) {
        setState(() {
          target = result["result"]["target"]?.toString() ?? "0";
        });
        await prefs.setString('target', target ?? "0");
      } else {
        debugPrint("Failed to fetch target: ${result["result"]["message"]}");
        setState(() {
          target = prefs.getString('target') ?? "0";
        });
      }
    } else {
      debugPrint("Failed to fetch target: ${response.statusCode}");
      setState(() {
        target = prefs.getString('target') ?? "0";
      });
    }
  } catch (e) {
    debugPrint("Error fetching target: $e");
    setState(() {
      target = prefs.getString('target') ?? "0";
    });
  }
}
  Future<void> loadOnedayHistory() async {
    try {
      final result = await _onedayagent.fetchOnedayHistory();
      setState(() {
        records = (result['records'] as List<dynamic>?)?.cast<Record>() ?? [];
        offerAcceptedCount = result['offer_accepted'] ?? 0;
        offerRejectedCount = result['offer_rejected'] ?? 0;
        alreadySubscribedCount = result['already_subscribed'] ?? 0;
      });
    } catch (e) {
      debugPrint("Error loading one day history: $e");
    }
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    dateController.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(localizations.salesrep)),
            Center(
              child: Text("${localizations.welcome} $agentname",
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const agentProfile())),
          )
        ],
      ),
      drawer: _buildDrawer(localeProvider, localizations),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Coustmer()),
          );
          await refreshData();
        },
        label: Text(localizations.customerform,
            style: const TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add_box_outlined, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Center(
                        child: Text(dateController.text,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.houseVisited,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final userId = prefs.getInt('id');
                              final token = prefs.getString('apikey');

                              if (userId != null && token != null) {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => edittarget(
                                      userId: userId,
                                      token: token,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await fetchTarget();
                                  setState(() {});
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Missing user ID or token")),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                        localizations.todaysHouseCount, target ?? "0"),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Onedayhistory())),
                      child: _buildInfoRow(
                          localizations.houseVisited, "${records.length}"),
                    ),
                    _buildInfoRow(localizations.todaysTargetLeft,
                        "${(int.tryParse(target ?? "0") ?? 0) - records.length}"),
                    const SizedBox(height: 30),
                    Row(children: [
                      Center(
                          child: _buildSectionTitle(localizations.myRouteMap)),
                      Spacer(),
                      TextButton.icon(
                        icon: Icon(Icons.assignment_outlined, size: 18),
                        label: Text(localizations.routemapassign,
                            style: TextStyle(fontSize: 14)),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('apikey');
                          final agentId = prefs.getInt('id');

                          if (token != null && agentId != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Agentaddrouite(
                                  agentId: agentId,
                                  token: token,
                                ),
                              ),
                            ).then((_) => refreshData());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Missing Agent ID or Token")),
                            );
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 8),
                    if (fullRouteMap?.result?.assigned != null)
                      ...fullRouteMap!.result!.assigned!.map((assigned) =>
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Route ID: ${assigned.id}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextButton.icon(
                                    onPressed: () {
                                      if (assigned.id != null) {
                                        final fromToIds = assigned.fromTo
                                                ?.map((ft) => {
                                                      "id": ft.id,
                                                      "from_location":
                                                          ft.fromLocation,
                                                      "to_location":
                                                          ft.toLocation,
                                                      "extra_points": ft
                                                          .extraPoints
                                                          ?.map((ep) => {
                                                                "id": ep.id,
                                                                "name": ep.name,
                                                              })
                                                          .toList(),
                                                    })
                                                .toList() ??
                                            [];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => Addextrapoint(
                                              routeId: assigned.id!,
                                              fromToIds: fromToIds,
                                            ),
                                          ),
                                        ).then((_) {
                                          refreshData();
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text("Edit Route",
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...?assigned.fromTo?.map(
                                (ft) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 20, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Text(ft.fromLocation ?? 'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  const Icon(
                                                      Icons.arrow_forward,
                                                      size: 16),
                                                  if (ft.extraPoints != null &&
                                                      ft.extraPoints!
                                                          .isNotEmpty) ...[
                                                    ...ft.extraPoints!
                                                        .map((ep) => Row(
                                                              children: [
                                                                Text(
                                                                    ep.name ??
                                                                        '',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black)),
                                                                const Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 16),
                                                              ],
                                                            )),
                                                  ],
                                                  Text(ft.toLocation ?? 'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    const SizedBox(height: 30),
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
            ),
    );
  }

  Widget _buildDrawer(
      LocalizationProvider localeProvider, AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 60),
                const SizedBox(height: 10),
                Text(" $agentname", style: const TextStyle(fontSize: 16)),
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
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(localizations.historyPage),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Historypage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline));

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      );

  Widget _buildBulletPoint(String text) => Padding(
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