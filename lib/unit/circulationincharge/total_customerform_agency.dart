import 'dart:convert';
import 'dart:typed_data';

import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_customerforms_agent.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/total_history.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TotalCustomerformAgency extends StatefulWidget {
  final User user;
  const TotalCustomerformAgency({super.key,required this.user});
  @override
  State<TotalCustomerformAgency> createState() => _TotalCustomerformAgencyState();
}

class _TotalCustomerformAgencyState extends State<TotalCustomerformAgency> {
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
  Future<Map<String, Object>?> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    // final userid = prefs.getInt('id');

    if (apikey == null || widget.user.id == null) {
      print("Missing user credentials: apiKey=$apikey, userId=${widget.user.id}");
      return null;
    }

    try {
      print(
          "📍 Calling API at https://salesrep.esanchaya.com/api/customer_forms_info_id with userId=${widget.user.id}");

      final response = await http
          .post(
            Uri.parse(
                "https://salesrep.esanchaya.com/api/customer_forms_info_id"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "user_id": widget.user.id.toString(), // Ensure it's a string
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

        await prefs.setInt('today_count', records.length);
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
  List<String> getUniqueAgencyNames(List<Records> records) {
  final Set<String> uniqueAgencies = {};

  for (var record in records) {
    if (record.agency != null && record.agency!.isNotEmpty&& record.agency != 'N/A'&& record.agency != 'false') {
      uniqueAgencies.add(record.agency!);
    }
  }

  return uniqueAgencies.toList()..sort();
}    

@override
Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;

  final uniqueAgencies = getUniqueAgencyNames(_filteredRecords);

  return Scaffold(
    appBar: AppBar(
      title: Text('TotalAgencies (${uniqueAgencies.length})'),
    ),
    body: RefreshIndicator(
      onRefresh: _fetchHistory,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : uniqueAgencies.isEmpty
              ? Center(
                  child: Text(
                    localizations.norecordsfound,
                    style: const TextStyle(fontSize: 18),
                  ),
               )
              : ListView.builder(
  padding: const EdgeInsets.only(bottom: 16),
  itemCount: uniqueAgencies.length,
  itemBuilder: (context, index) {
    final agencyName = uniqueAgencies[index];

    // Count how many records belong to this agency
    final count = _filteredRecords.where((r) => r.agency == agencyName).length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TotalCustomerformsAgent(user: widget.user, agencyName: agencyName),
          ),
        );
      },
      child: ListTile(
        title: Text(agencyName),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "(${count.toString()})",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 16),
          ),
        ),
      ),
    );
  },
),

    ),
  );
}


  // Widget _buildStat(String label, int count, Color color) => Column(
  //       children: [
  //         Text(label,
  //             style:
  //                 const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  //         const SizedBox(height: 4),
  //         Text("$count",
  //             style: TextStyle(
  //                 fontSize: 18, fontWeight: FontWeight.bold, color: color)),
  //       ],
  //     );


  // Widget _base64ImageWidget(String label, String base64String) {
  //   try {
  //     final cleanedBase64 = base64String.contains(',')
  //         ? base64String.split(',').last
  //         : base64String;

  //     final decodedBytes = base64Decode(cleanedBase64);

  //     return Padding(
  //       padding: const EdgeInsets.only(bottom: 12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("$label:",
  //               style: const TextStyle(fontWeight: FontWeight.w600)),
  //           const SizedBox(height: 6),
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (_) => FullscreenImageView(
  //                     imageBytes: decodedBytes,
  //                     label: label,
  //                   ),
  //                 ),
  //               );
  //             },
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(10),
  //               child: Image.memory(
  //                 decodedBytes,
  //                 height: 180,
  //                 width: double.infinity,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint("Base64 decoding error: $e");
  //     return const SizedBox.shrink();
  //   }
  // }

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
