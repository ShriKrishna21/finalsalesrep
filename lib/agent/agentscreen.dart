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
import 'package:image_picker/image_picker.dart';
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

class startworkselfiemodel {
  String? jsonrpc;
  Null? id;
  Result? result;

  startworkselfiemodel({this.jsonrpc, this.id, this.result});

  startworkselfiemodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class endworkselfiekmodel {
  String? jsonrpc;
  Null? id;
  Result? result;

  endworkselfiekmodel({this.jsonrpc, this.id, this.result});

  endworkselfiekmodel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  bool? success;
  String? message;
  int? code;

  Result({this.success, this.message, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

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
  String? selectedSelfieType;

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
    await fetchTarget();
    setState(() => _isLoading = false);
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
          setState(() {
            target = prefs.getString('target') ?? "0";
          });
        }
      } else {
        setState(() {
          target = prefs.getString('target') ?? "0";
        });
      }
    } catch (e) {
      setState(() {
        target = prefs.getString('target') ?? "0";
      });
    }
  }

  Future<void> _uploadSelfie(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or missing token/user ID')),
      );
      return;
    }

    String apiUrl;
    switch (type) {
      case 'login':
        apiUrl = "https://salesrep.esanchaya.com/api/start_work";
        break;
      case 'logout':
        apiUrl = "https://salesrep.esanchaya.com/api/end_work";
        break;
      default:
        apiUrl = "https://salesrep.esanchaya.com/api/user/today_selfies";
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "user_id": userId,
            "token": token,
            "type": type == 'login' || type == 'logout' ? null : type,
            "selfie": base64Image,
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        bool success = false;
        String message = '';

        if (type == 'login') {
          final selfieModel = startworkselfiemodel.fromJson(responseData);
          success = selfieModel.result?.success ?? false;
          message = selfieModel.result?.message ?? 'Login selfie uploaded';
        } else if (type == 'logout') {
          final selfieModel = endworkselfiekmodel.fromJson(responseData);
          success = selfieModel.result?.success ?? false;
          message = selfieModel.result?.message ?? 'Logout selfie uploaded';
        } else {
          success = responseData['result']?['success'] ?? false;
          message =
              responseData['result']?['message'] ?? 'Selfie $type uploaded';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success
                  ? '$message successfully'
                  : 'Failed to upload selfie: $message')),
        );
        await refreshData();
      } else {
        debugPrint("Upload failed: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload selfie: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Error uploading selfie: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading selfie: $e')),
      );
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
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
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            backgroundColor: Colors.white,
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Selfie Type'),
                  content: DropdownButton<String>(
                    value: selectedSelfieType,
                    hint: const Text('Choose a type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'login',
                        child: Text('Login Selfie'),
                      ),
                      DropdownMenuItem(
                        value: 'lunch',
                        child: Text('Lunch Selfie'),
                      ),
                      DropdownMenuItem(
                        value: 'after_lunch',
                        child: Text('After Lunch Selfie'),
                      ),
                      DropdownMenuItem(
                        value: 'logout',
                        child: Text('Logout Selfie'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSelfieType = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
              if (selectedSelfieType != null) {
                await _uploadSelfie(selectedSelfieType!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a selfie type')),
                );
              }
            },
            label: const Text('Take Selfie',
                style: TextStyle(color: Colors.black)),
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
          ),
        ],
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
                      child: Text(
                        "Name of the Staff: $agentname",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.houseVisited,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
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
                                      content:
                                          Text("Missing user ID or token")),
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
                        "Customers the Promoter has met", "${records.length}"),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Onedayhistory()),
                      ),
                      child: _buildInfoRow("Houses Visited",
                          "${records.length} house${records.length == 1 ? '' : 's'} visited"),
                    ),
                    const SizedBox(height: 8),
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
