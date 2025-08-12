import 'dart:convert';
import 'dart:typed_data';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class unittotalcustomerforms extends StatefulWidget {
  final int userid;

  const unittotalcustomerforms({super.key, required this.userid});

  @override
  State<unittotalcustomerforms> createState() => _unittotalcustomerformsState();
}

class _unittotalcustomerformsState extends State<unittotalcustomerforms> {
  Map<String, List<Records>> _groupedRecords = {};
  Map<String, List<Records>> _filteredGroupedRecords = {};
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<Map<String, Object>?> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');

    if (apikey == null || widget.userid == null) {
      debugPrint("Missing user credentials: apiKey=$apikey, userId=${widget.userid}");
      return null;
    }

    try {
      debugPrint(
          "📍 Calling API at https://salesrep.esanchaya.com/api/customer_forms_info_id with userId=${widget.userid}");

      final response = await http
          .post(
            Uri.parse(
                "https://salesrep.esanchaya.com/api/customer_forms_info_id"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "user_id": widget.userid.toString(),
                "token": apikey,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final historyData = Historymodel.fromJson(jsonResponse);
        final records = historyData.result?.records ?? [];

        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in records) {
          if (record.eenaduNewspaper == true) {
            subscribed++;
          } else {
            if (record.freeOffer15Days == true) {
              accepted++;
            } else if (record.freeOffer15Days == false &&
                record.eenaduNewspaper == false) {
              rejected++;
            }
          }
        }

        await prefs.setInt('total_count', records.length);
        await prefs.setInt('offer_accepted', accepted);
        await prefs.setInt('offer_rejected', rejected);
        await prefs.setInt('already_subscribed', subscribed);

        return {
          'records': records,
          'offer_accepted': accepted,
          'offer_rejected': rejected,
          'already_subscribed': subscribed,
        };
      } else {
        debugPrint("❌ API Error: ${response.statusCode} ${response.reasonPhrase}");
        return null;
      }
    } catch (error) {
      debugPrint("❌ Fetch error: $error");
      return null;
    }
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final result = await fetchCustomerForm();
    if (result != null) {
      final all = result['records'] as List<Records>;
      final accepted = result['offer_accepted'] as int;
      final rejected = result['offer_rejected'] as int;
      final subscribed = result['already_subscribed'] as int;

      // Group records by agency
      Map<String, List<Records>> grouped = {};
      for (var record in all) {
  final agency = record.agency?.trim() ?? '';
  if (agency.isEmpty || agency.toLowerCase() == 'false') {
    continue; // Skip invalid agency names
  }
  if (!grouped.containsKey(agency)) {
    grouped[agency] = [];
  }
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
        offerAcceptedCount = accepted;
        offerRejectedCount = rejected;
        alreadySubscribedCount = subscribed;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch records')),
      );
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGroupedRecords = Map.from(_groupedRecords);
      } else {
        final lower = query.toLowerCase();
        _filteredGroupedRecords = {};
        _groupedRecords.forEach((agency, records) {
          final filtered = records.where((r) {
            final idMatch =
                r.id?.toString().toLowerCase().contains(lower) ?? false;
            final familyNameMatch =
                r.familyHeadName?.toLowerCase().contains(lower) ?? false;
            final agencyMatch = agency.toLowerCase().contains(lower);
            return idMatch || familyNameMatch || agencyMatch;
          }).toList();
          if (filtered.isNotEmpty) {
            _filteredGroupedRecords[agency] = filtered;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Total Customer Forms (${_filteredGroupedRecords.values.fold(0, (sum, records) => sum + records.length)})"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Customer forms for ${widget.userid ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRecords,
                decoration: InputDecoration(
                  hintText: localizations.searchbyidorfamilyheadname,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(localizations.accepted, offerAcceptedCount, Colors.green),
                  _buildStat(localizations.rejected, offerRejectedCount, Colors.red),
                  _buildStat(localizations.subscribed, alreadySubscribedCount, Colors.blue),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredGroupedRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Text(
                    localizations.norecordsfound,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              ..._filteredGroupedRecords.entries.map((entry) {
                final agency = entry.key;
                final records = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      "$agency (${records.length})",
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
              }),
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

  Widget _buildRecordCard(Records r, AppLocalizations localizations) {
    return Card(
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          "Customer Name: ${r.familyHeadName ?? 'N/A'}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Staff", r.agentName),
                _detailRow("Agency", r.agency),
                _detailRow(localizations.date, r.date),
                _detailRow(localizations.time, r.time),
                _detailRow("Customer Name", r.familyHeadName),
                _detailRow("Age", r.age),
                _detailRow("Mobile Number", r.mobileNumber),
                const Text("Newspaper Details"),
                _detailRow("Customer Type", r.customerType),
                _detailRow("Previous Newspaper", r.currentNewspaper),
                _detailRow("Start Circulating", r.startCirculating),
                _detailRow(localizations.city, r.city),
                _detailRow(localizations.address, r.address),
                _detailRow(localizations.employed, _formatBool(r.employed)),
                _detailRow("Occupation", _formatBool(r.occupation)),
                _detailRow(localizations.jobtype, r.jobType),
                _detailRow(localizations.jobWorkingstate,
                    _formatBool(r.jobWorkingState)),
                if (r.locationUrl != null &&
                    r.locationUrl!.isNotEmpty &&
                    r.locationUrl != 'false' &&
                    r.locationUrl != 'N/A')
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
                              r.locationUrl!,
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
                  _base64ImageWidget("Landmark Photo", r.faceBase64!),
              ],
            ),
          ),
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

  bool _isValidValue(dynamic value) {
    if (value == null) return false;
    if (value is String)
      return value.isNotEmpty && value != 'false' && value != 'N/A';
    if (value is bool) return value == true;
    return true;
  }

  Widget _detailRow(String label, dynamic value) {
    if (!_isValidValue(value)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(_formatValue(value))),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is bool) {
      return _formatBool(value);
    }
    return value?.toString() ?? 'N/A';
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
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 5,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
