import 'dart:convert';
import 'dart:typed_data';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_customerform_agency.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Unittodaycustomerforms extends StatefulWidget {
  final int userid;
  const Unittodaycustomerforms({super.key, required this.userid});

  @override
  State<Unittodaycustomerforms> createState() => _UnittodaycustomerformsState();
}

class _UnittodaycustomerformsState extends State<Unittodaycustomerforms> {
  bool _isLoading = true;
  Map<String, List<Record>> _groupedRecords = {};
  Map<String, List<Record>> _filteredGroupedRecords = {};

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final TextEditingController _searchController = TextEditingController();

  Future<Map<String, dynamic>> fetchOnedayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');

    if (apikey == null || widget.userid == null) {
      print("❌ Missing user credentials: apikey or id is null");
      return {'error': 'Missing credentials'};
    }

    final apiUrl = CommonApiClass.oneDayAgent;

    print("📡 Hitting API: $apiUrl");
    print("📦 Payload: ${jsonEncode({
          "params": {
            "user_id": widget.userid,
            "token": apikey,
          }
        })}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "user_id": widget.userid,
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

        print(
            "📊 Final Counts → Subscribed: $subscribed, Accepted: $accepted, Rejected: $rejected");

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

  Future<void> loadOnedayHistory() async {
    setState(() => _isLoading = true);
    final result = await fetchOnedayHistory();
    print('API Response: $result');

    if (result.containsKey('error')) {
      setState(() {
        _isLoading = false;
        _groupedRecords = {};
        _filteredGroupedRecords = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch records: ${result['error']}')),
      );
      return;
    }

    final fetchedRecords = (result['records'] as List<Record>?) ?? [];

    // Group records by agency
    Map<String, List<Record>> grouped = {};
    for (var record in fetchedRecords) {
      final agency = record.agency?.trim() ?? '';
      if (agency.isEmpty || agency.toLowerCase() == 'false') {
        continue; // Skip invalid agency names
      }
      grouped.putIfAbsent(agency, () => []);
      grouped[agency]!.add(record);
    }

    // Sort records within each agency by id (descending)
    grouped.forEach((agency, records) {
      records.sort((a, b) {
        final idA = int.tryParse(a.id.toString()) ?? 0;
        final idB = int.tryParse(b.id.toString()) ?? 0;
        return idB.compareTo(idA);
      });
    });

    setState(() {
      _groupedRecords = grouped;
      _filteredGroupedRecords = Map.from(grouped);
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
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGroupedRecords = Map.from(_groupedRecords);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredGroupedRecords = {};
        _groupedRecords.forEach((agency, records) {
          final filtered = records.where((r) {
            final id = r.id?.toString().toLowerCase() ?? '';
            final name = r.agentName?.toLowerCase() ?? '';
            final familyHead = r.familyHeadName?.toLowerCase() ?? '';
            final agencyMatch = agency.toLowerCase().contains(lowerQuery);
            return id.contains(lowerQuery) ||
                name.contains(lowerQuery) ||
                familyHead.contains(lowerQuery) ||
                agencyMatch;
          }).toList();
          if (filtered.isNotEmpty) {
            _filteredGroupedRecords[agency] = filtered;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadOnedayHistory();
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
        title: Text(
          '${localizations.todayhistory} (${_filteredGroupedRecords.values.fold(0, (sum, records) => sum + records.length)})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadOnedayHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
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
                          _buildStat(
                              localizations.accepted, offerAcceptedCount, Colors.green),
                          _buildStat(
                              localizations.rejected, offerRejectedCount, Colors.red),
                          _buildStat(localizations.subscribed,
                              alreadySubscribedCount, Colors.blue),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // 📋 Agency Grouped Records or No Records Message
                    _filteredGroupedRecords.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                localizations.norecordsfound,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        : Column(
                            children: _filteredGroupedRecords.entries.map((entry) {
                              final agency = entry.key;
                              final records = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ExpansionTile(
                                  title: Text(
                                    agency,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  children: records
                                      .map((record) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: _buildRecordCard(record, localizations),
                                          ))
                                      .toList(),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
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

    String locationText = hasValidCoordinates
        ? 'View on Google Maps'
        : hasValidLocationUrl
            ? r.locationUrl!
            : 'Not available';
    return Card(
      elevation: 3,
      child: ExpansionTile(
        title: Text("Customer Name: ${r.familyHeadName ?? 'N/A'}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Agent Name", r.agentName),
                _detailRow("Agency", r.agency),
                _detailRow("Date", r.date),
                _detailRow("Time", r.time),
                _detailRow("Customer Name", r.familyHeadName),
                _detailRow("Age", r.age),
                _detailRow("Mobile Number", r.mobileNumber),
                const Text("News Paper Details:"),
                _detailRow("Customer Type", r.customerType),
                _detailRow("Previous Newspaper", r.currentNewspaper),
                _detailRow("Start Circulating", r.startCirculating),
                _detailRow("City", r.city),
                _detailRow("Address", r.address),
                _detailRow("Employed", _formatBool(r.employed)),
                _detailRow("Job Type", r.jobType),
                _detailRow("Job Profession", r.jobProfession),
                _detailRow("Job Designation", r.jobDesignation),
                _detailRow("Company Name", r.companyName),
                _detailRow("Profession", r.profession),
                _detailRow("Job Working State", r.jobWorkingState),
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
                            locationText,
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

  Widget _detailRow(String label, dynamic value) {
    if (value == null || value == false || value == "") {
      return const SizedBox.shrink();
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

class FullscreenImageView extends StatelessWidget {
  final Uint8List imageBytes;
  final String label;

  const FullscreenImageView({
    super.key,
    required this.imageBytes,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}