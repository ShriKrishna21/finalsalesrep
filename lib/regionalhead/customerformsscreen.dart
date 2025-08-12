import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/modelclasses/customerformsunitwise.dart';

class Customerformsscreen extends StatefulWidget {
  final String? unitName;
  const Customerformsscreen({super.key, required this.unitName});

  @override
  State<Customerformsscreen> createState() => _CustomerformsscreenState();
}

class _CustomerformsscreenState extends State<Customerformsscreen> {
  List<Records> _records = [];
  List<Records> _filteredRecords = [];
  bool _isLoading = false;
  DateTimeRange? _selectedRange;
  final TextEditingController _searchController = TextEditingController();
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;
  String? _selectedAgency;
  List<String> _agencies = [];

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

    if (apikey == null || widget.unitName == null) {
      print("Missing credentials: apiKey=$apikey, unitName=${widget.unitName}");
      return null;
    }

    String fromDate = '';
    String toDate = '';
    if (_selectedRange != null) {
      fromDate = _selectedRange!.start.toIso8601String().split('T')[0];
      toDate = _selectedRange!.end.toIso8601String().split('T')[0];
    }

    try {
      const apiUrl =
          'https://salesrep.esanchaya.com/api/customer_forms_filtered';
      final params = {
        'token': apikey,
        'from_date': fromDate,
        'to_date': toDate,
        'unit_name': widget.unitName,
        'order': 'desc',
      };

      print(
          "📍 Calling API at $apiUrl with params: ${jsonEncode({'params': params})}");

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'params': params}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = AllCustomerForms.fromJson(jsonResponse);
        if (data.result?.success == true && data.result?.records != null) {
          final records = data.result!.records!;

          // Filter out records where agency is 'false' or empty
          final filteredRecords = records
              .where((r) =>
                  r.agency != null &&
                  r.agency!.isNotEmpty &&
                  r.agency!.toLowerCase() != 'false')
              .toList();

          int subscribed = 0;
          int accepted = 0;
          int rejected = 0;

          // Calculate counts (uncomment and adjust as needed, using filteredRecords)
          // for (var record in filteredRecords) {
          //   if (record.eenaduNewspaper == true) {
          //     subscribed++;
          //   } else {
          //     if (record.freeOffer15Days == true) {
          //       accepted++;
          //     } else if (record.freeOffer15Days == false &&
          //         record.eenaduNewspaper == false) {
          //       rejected++;
          //     }
          //   }
          // }

          // Extract unique agency names from filtered records
          final agencies = filteredRecords
              .map((r) => r.agency!)
              .toSet()
              .toList();

          await prefs.setInt('today_count', filteredRecords.length);
          await prefs.setInt('offer_accepted', accepted);
          await prefs.setInt('offer_rejected', rejected);
          await prefs.setInt('already_subscribed', subscribed);

          return {
            'records': filteredRecords,
            'offer_accepted': accepted,
            'offer_rejected': rejected,
            'already_subscribed': subscribed,
            'agencies': agencies,
          };
        } else {
          print("No records or success false: ${data.result?.code}");
          return null;
        }
      } else {
        print("❌ API Error: ${response.statusCode} ${response.reasonPhrase}");
        return null;
      }
    } catch (error) {
      print("❌ Fetch error: $error");
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
      final agencies = result['agencies'] as List<String>;

      var filtered = all;

      filtered.sort((a, b) {
        final idA = int.tryParse(a.id.toString()) ?? 0;
        final idB = int.tryParse(b.id.toString()) ?? 0;
        return idB.compareTo(idA);
      });

      setState(() {
        _records = filtered;
        _agencies = ['All', ...agencies];
        _selectedAgency = 'All';
        _filteredRecords = filtered;
        offerAcceptedCount = accepted;
        offerRejectedCount = rejected;
        alreadySubscribedCount = subscribed;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
      _fetchHistory();
    }
  }

  void _filterRecords(String query) {
    setState(() {
      var filtered = _records;

      // Apply agency filter
      if (_selectedAgency != null && _selectedAgency != 'All') {
        filtered = filtered
            .where((r) => r.agency == _selectedAgency)
            .toList();
      }

      // Apply search query filter
      if (query.isNotEmpty) {
        final lower = query.toLowerCase();
        filtered = filtered.where((r) {
          final idMatch =
              r.id?.toString().toLowerCase().contains(lower) ?? false;
          final familyNameMatch =
              r.familyHeadName?.toLowerCase().contains(lower) ?? false;
          return idMatch || familyNameMatch;
        }).toList();
      }

      _filteredRecords = filtered;
    });
  }

  void _onAgencySelected(String? agency) {
    setState(() {
      _selectedAgency = agency;
      _filterRecords(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${localizations.totalhistory} (${_filteredRecords.length})'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Card(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: GestureDetector(
                  onTap: _pickDateRange,
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _selectedRange == null
                            ? localizations.alldates
                            : "${_selectedRange!.start.toLocal().toString().split(' ')[0]} → ${_selectedRange!.end.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedAgency,
                decoration: InputDecoration(
                  labelText: 'Agency (${_agencies.length - 1})',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _agencies.map((agency) {
                  return DropdownMenuItem<String>(
                    value: agency,
                    child: Text(agency),
                  );
                }).toList(),
                onChanged: _onAgencySelected,
              ),
            ),
            if (_selectedRange != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_center_focus),
                    label: Text(localizations.fetchcustomerforms),
                    onPressed: _fetchHistory,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
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
                  // _buildStat(
                  //     localizations.accepted, offerAcceptedCount, Colors.green),
                  // _buildStat(
                  //     localizations.rejected, offerRejectedCount, Colors.red),
                  // _buildStat(localizations.subscribed, alreadySubscribedCount,
                  //     Colors.blue),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredRecords.isEmpty)
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
              ..._filteredRecords.map((record) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                _detailRow("Customer Name", r.familyHeadName),
                _detailRow("Age", r.age),
                _detailRow("Mobile Number", r.mobileNumber),
                const Text("News-paper Details"),
                _detailRow("Customer Type", r.customerType),
                _detailRow("Start Circulating", r.startCirculating),
                _detailRow(localizations.city, r.city),
                _detailRow(localizations.address, r.address),
                _detailRow(localizations.employed, _formatBool(r.employed)),
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
                  _base64ImageWidget("Landmark photo", r.faceBase64!),
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