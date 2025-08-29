import 'dart:convert';

import 'package:finalsalesrep/agent/historypage.dart' hide AppLocalizations;
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ToadayCustomerformsAgent extends StatefulWidget {
  final User user;
  final String? agencyName;
  const ToadayCustomerformsAgent({super.key, required this.user, this.agencyName});

  @override
  State<ToadayCustomerformsAgent> createState() => _ToadayCustomerformsAgentState();
}

class _ToadayCustomerformsAgentState extends State<ToadayCustomerformsAgent> {
  List<Record> records = [];
  List<Record> filteredRecords = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOnedayHistory();
  }
 Future<Map<String, dynamic>> fetchOnedayHistoryy() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    // final userid = prefs.getInt('id');

    if (apikey == null || widget.user.id == null) {
      print("❌ Missing user credentials: apikey or id is null");
      return {'error': 'Missing credentials'};
    }

    final apiUrl = CommonApiClass.oneDayAgent;

    print("📡 Hitting API: $apiUrl");
    print("📦 Payload: ${jsonEncode({
      "params": {
        "user_id": widget.user.id,
        "token": apikey,
      }
    })}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "user_id": widget.user.id,
            "token": apikey,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      print("🔁 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Response: $jsonResponse");

        final historyoneday = OneDayHistory.fromJson(jsonResponse);
        final records = historyoneday.result?.records ?? [];

        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in records) {
          final isSubscribed = record.eenaduNewspaper == true;
          final isAccepted = record.freeOffer15Days == true;
          final isRejected = record.freeOffer15Days == false;

          if (isSubscribed) {
            subscribed++;
          } else {
            if (isAccepted) accepted++;
            if (isRejected) rejected++;
          }
        }

        print("📊 Final Counts → Subscribed: $subscribed, Accepted: $accepted, Rejected: $rejected");

        // Save locally
        await prefs.setInt('today_count', records.length);
        await prefs.setInt('offer_accepted', accepted);
        await prefs.setInt('offer_rejected', rejected);
        await prefs.setInt('already_subscribed', subscribed);

        print("✅ Saved all counts to SharedPreferences");

        return {
          'records': records,
          'offer_accepted': accepted,
          'offer_rejected': rejected,
          'already_subscribed': subscribed,
        };
      } else {
        print("❌ Server returned error: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return {'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print("❌ Network/Parsing error: $e");
      return {'error': 'Network or unexpected error'};
    }
  }
// 8566682
Future<void> loadOnedayHistory() async {
  setState(() => _isLoading = true);
  final result = await fetchOnedayHistoryy();
  print('API Response: $result');

  List<Record> fetchedRecords = (result['records'] as List<Record>?) ?? [];

  // If agencyName is given, filter records by agencyName (case-insensitive)
  if (widget.agencyName != null && widget.agencyName!.isNotEmpty) {
    fetchedRecords = fetchedRecords.where((record) {
      return (record.agency ?? '').toLowerCase() == widget.agencyName!.toLowerCase();
    }).toList();
  }

  setState(() {
    records = fetchedRecords.reversed.toList();
    filteredRecords = List.from(records);
    offerAcceptedCount = result['offer_accepted'] ?? 0;
    offerRejectedCount = result['offer_rejected'] ?? 0;
    alreadySubscribedCount = result['already_subscribed'] ?? 0;
    _isLoading = false;
  });
}

  Future<void> openGoogleMaps(
      double? latitude, double? longitude, String? locationUrl) async {
    String url = '';

    if (latitude != null && longitude != null) {
      url =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    } else if (locationUrl != null &&
        locationUrl.isNotEmpty &&
        locationUrl != 'false' &&
        locationUrl != 'N/A') {
      url = locationUrl;
    }

    final uri = Uri.parse(url);

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw 'Could not launch';
      }
    } catch (e) {
      debugPrint('Could not launch $url');
      // Optional: show a dialog or snackbar
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecords = List.from(records);
      } else {
        final lowerQuery = query.toLowerCase();
        filteredRecords = records.where((r) {
          final id = r.id?.toString().toLowerCase() ?? '';
          final name = r.agentName?.toLowerCase() ?? '';
          final familyHead = r.familyHeadName?.toLowerCase() ?? '';
          return id.contains(lowerQuery) ||
              name.contains(lowerQuery) ||
              familyHead.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${localizations.todayhistory} (${filteredRecords.length})'),
      ),
      body: RefreshIndicator(
        onRefresh: loadOnedayHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredRecords.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 200),
                      Center(
                        child: Text(
                          localizations.norecordsfound,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      // 🔍 Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterRecords,
                          decoration: InputDecoration(
                            hintText: localizations.searchbyidorfamilyheadname,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      // 📊 Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // _buildStat(localizations.accepted,
                            //     offerAcceptedCount, Colors.green),
                            // _buildStat(localizations.rejected,
                            //     offerRejectedCount, Colors.red),
                            // _buildStat(localizations.subscribed,
                            //     alreadySubscribedCount, Colors.blue),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // 📋 Record List
                      ...filteredRecords.map((record) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: _buildRecordCard(record, localizations),
                          )),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) => Column(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("$count",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      );

  Widget _buildRecordCard(Record r, AppLocalizations localizations) {
    bool hasValidCoordinates = r.latitude != null &&
        r.longitude != null &&
        double.tryParse(r.latitude!) != null &&
        double.tryParse(r.longitude!) != null;
    bool hasValidLocationUrl = r.locationUrl != null &&
        r.locationUrl != 'false' &&
        r.locationUrl != 'N/A' &&
        r.locationUrl!.isNotEmpty;

    // Determine display text
    String locationText = hasValidCoordinates
        ? 'View on Google Maps'
        : hasValidLocationUrl
            ? r.locationUrl!
            : 'Not available';
    return Card(
      elevation: 3,
      child: ExpansionTile(
        title: Text("customer Name: ${r.familyHeadName ?? 'N/A'}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("s", r.agentName),
                _detailRow("Agency", r.agency),
                // _detailRow(localizations.agentlogin, r.agentLogin),
                _detailRow(localizations.date, r.date),
                _detailRow(localizations.time, r.time),
                _detailRow("customer name", r.familyHeadName),
                _detailRow("Age", r.age),
                  _detailRow(localizations.mobilenumber, r.mobileNumber),
                
                  
                   Text("News paper Details:"),
                   _detailRow("customer type", r.customerType),
                   
                    _detailRow(" previous newspaper", r.currentNewspaper),
                       _detailRow("Start circulating", r.startCirculating),
                    // _detailRow(" Start Circulation", r.startCirculating),
                  

                // _detailRow(localizations.fathersname, r.fatherName),
                // _detailRow(localizations.mothername, r.motherName),
                // _detailRow(localizations.spousename, r.spouseName),
                _detailRow(localizations.city, r.city),
                _detailRow(localizations.address, r.address),
              
              
                // _detailRow(localizations.eenadunewspaper,
                //     _formatBool(r.eenaduNewspaper)),
                // _detailRow(
                //     localizations.readnewspaper, _formatBool(r.readNewspaper)),
                // _detailRow(
                //     localizations.freeoffer, _formatBool(r.freeOffer15Days)),
                // _detailRow(localizations.reasonfornottakingoffer,
                //     r.reasonNotTakingOffer),
                _detailRow(localizations.employed, _formatBool(r.employed)),
                _detailRow(localizations.jobtype, r.jobType),
                _detailRow(localizations.jobprofession, r.jobProfession),
                _detailRow(localizations.jobdesignation, r.jobDesignation),
                _detailRow(localizations.companyname, r.companyName),
                _detailRow(localizations.profession, r.profession),
                _detailRow(localizations.jobWorkingstate, r.jobWorkingState),
                _detailRow(localizations.profession, r.profession),
                _detailRow(localizations.jobWorkingstate, r.jobWorkingState),
               
                  Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Location URL: ",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            openGoogleMaps(
                              double.tryParse(r.latitude ?? ''),
                              double.tryParse(r.longitude ?? ''),
                              r.locationUrl,
                            );
                          },
                          child: Text(
                            r.locationUrl != null &&
                                    r.locationUrl != 'false' &&
                                    r.locationUrl != 'N/A'
                                ? r.locationUrl!
                                : 'View on Google Maps',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    
                // 📷 Display image from base64 if available
                if (r.faceBase64 != null && r.faceBase64!.isNotEmpty)
                  _base64ImageWidget("Landmark photo", r.faceBase64!),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _base64ImageWidget(String label, String base64String) {
    try {
      final cleanedBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;

      final decodedBytes = base64Decode(cleanedBase64);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$label:",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageView(
                      imageBytes: decodedBytes,
                      label: label,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  decodedBytes,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Base64 decoding error: $e");
      return const SizedBox.shrink();
    }
  }

  /// 🔧 Fixed version to support any type (String/bool/null)

  Widget _detailRow(String label, dynamic value) {
        if (value == null || value == false || value == "") {
    return const SizedBox.shrink(); // Return empty widget if invalid
  }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  String _formatBool(bool? v) {
    if (v == true) return 'Yes';
    if (v == false) return 'No';
    return 'N/A';
  }
}
