import 'dart:convert';
import 'dart:typed_data';

import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/total_history.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});
  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  List<Records> _records = [];
  List<Records> _filteredRecords = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final TotalHistory _historyFetcher = TotalHistory();

  DateTimeRange? _selectedRange;
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

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final result = await _historyFetcher.fetchCustomerForm();
    if (result != null) {
      final all = result['records'] as List<Records>;
      final accepted = result['offer_accepted'] as int;
      final rejected = result['offer_rejected'] as int;
      final subscribed = result['already_subscribed'] as int;

      var filtered = all;
      if (_selectedRange != null) {
        final s = _selectedRange!.start;
        final e = _selectedRange!.end.add(const Duration(days: 1));
        filtered = all.where((r) {
          final dt = _combineDateTime(r.date, r.time);
          return dt.isAfter(s.subtract(const Duration(milliseconds: 1))) &&
              dt.isBefore(e);
        }).toList();
      }

      filtered.sort((a, b) {
        final idA = int.tryParse(a.id.toString()) ?? 0;
        final idB = int.tryParse(b.id.toString()) ?? 0;
        return idB.compareTo(idA);
      });

      setState(() {
        _records = filtered;
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

  DateTime _combineDateTime(String? date, String? time) {
    if (date == null || date.isEmpty) return DateTime(1970);
    try {
      final datePart = DateTime.parse(date);
      if (time != null && time.isNotEmpty && time.contains(":")) {
        final parts = time.split(":");
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
        return DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          hour,
          minute,
          second,
        );
      }
      return datePart;
    } catch (_) {
      return DateTime(1970);
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
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = List.from(_records);
      } else {
        final lower = query.toLowerCase();
        _filteredRecords = _records.where((r) {
          final idMatch =
              r.id?.toString().toLowerCase().contains(lower) ?? false;
          final familyNameMatch =
              r.familyHeadName?.toLowerCase().contains(lower) ?? false;
          return idMatch || familyNameMatch;
        }).toList();
      }
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 12),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _buildStat(
            //           localizations.accepted, offerAcceptedCount, Colors.green),
            //       _buildStat(
            //           localizations.rejected, offerRejectedCount, Colors.red),
            //       _buildStat(localizations.subscribed, alreadySubscribedCount,
            //           Colors.blue),
            //     ],
            //   ),
            // ),
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
          "customer Name: ${r.familyHeadName ?? 'N/A'}",
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
                _detailRow("customer name", r.familyHeadName),
                _detailRow("Age", r.age),
                _detailRow("mobile Number", r.mobileNumber),
                Text("News-paper Details"),
                _detailRow("Customer Type", r.customerType),
                _detailRow("previous News-paper", r.currentNewspaper),
                _detailRow("Start Circulating", r.startCirculating),
                _detailRow(localizations.city, r.city),
                _detailRow(localizations.address, r.address),
                _detailRow(localizations.employed, _formatBool(r.employed)),
                // _detailRow(
                //     localizations.subscribed, _formatBool(r.eenaduNewspaper)),
                // _detailRow(
                //     localizations.readnewspaper, _formatBool(r.readNewspaper)),
                // _detailRow(localizations.reasonfornottakingoffer,
                //     r.reasonNotTakingOffer),
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
