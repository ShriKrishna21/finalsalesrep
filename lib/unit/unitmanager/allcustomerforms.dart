import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/customerformsunitwise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Allcustomerforms extends StatefulWidget {
  const Allcustomerforms({super.key});

  @override
  State<Allcustomerforms> createState() => _AllcustomerformsState();
}

class _AllcustomerformsState extends State<Allcustomerforms> {
  List<Records> records = [];
  List<Records> filteredRecords = [];

  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int offerAcceptedCount = 0;
  // int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    fetchAllForms();
    _searchController.addListener(() {
      _filterRecords(_searchController.text);
    });
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
      // Optional: show a dialog or snackbar
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
      fetchAllForms();
    }
  }

  void _filterRecords(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredRecords = records.where((record) {
        final name = record.familyHeadName?.toLowerCase() ?? '';
        final id = record.id?.toString() ?? '';
        final mobile = record.mobileNumber?.toLowerCase() ?? '';
        final agent = record.agentName?.toLowerCase() ?? '';
        return name.contains(searchQuery) ||
            id.contains(searchQuery) ||
            mobile.contains(searchQuery) ||
            agent.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> fetchAllForms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (token == null || unitName == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Missing token or unit name';
      });
      return;
    }

    String fromDate = "";
    String toDate = "";

    if (_selectedRange != null) {
      fromDate = _selectedRange!.start.toIso8601String().split('T')[0];
      toDate = _selectedRange!.end.toIso8601String().split('T')[0];
    }

    final requestBody = {
      "params": {
        "token": token,
        "from_date": fromDate,
        "to_date": toDate,
        "unit_name": unitName,
        "agent_name": "",
        "order": "asc",
      }
    };
    print(requestBody);
    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/customer_forms_filtered'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = AllCustomerForms.fromJson(jsonDecode(response.body));
        final fetchedRecords = (data.result?.records ?? []).reversed.toList();

        int subscribed = 0;

        setState(() {
          records = fetchedRecords;
          filteredRecords = fetchedRecords;
          alreadySubscribedCount = subscribed;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data. Try again later.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong: $e";
        isLoading = false;
      });
      print("Error Message: $errorMessage");
      //print( "Error fetching data: $e");
    }
  }

  String _boolToText(bool? value) {
    final localizations = AppLocalizations.of(context)!;
    if (value == null) return 'N/A';
    return value ? localizations.yes : localizations.no;
  }

  String _cleanBase64(String input) {
    if (input.contains(',')) {
      return input.split(',').last;
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(localizations.viewallcustomerforms),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text("\u26a0\ufe0f $errorMessage"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: ElevatedButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(_selectedRange == null
                            ? localizations.filterbydate
                            : "${_selectedRange!.start.toLocal().toString().split(' ')[0]} → ${_selectedRange!.end.toLocal().toString().split(' ')[0]}"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(" Summary",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                                " ${localizations.eenaduSubscription}: $alreadySubscribedCount"),
                            Text(
                                " ${localizations.daysOfferAccepted15}: $offerAcceptedCount"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredRecords.isEmpty
                          ? Center(
                              child:
                                  Text(localizations.nocustomerformsavailable))
                          : RefreshIndicator(
                              onRefresh: fetchAllForms,
                              child: ListView.builder(
                                itemCount: filteredRecords.length,
                                itemBuilder: (context, index) {
                                  final r = filteredRecords[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${localizations.familyheadname}: ${r.familyHeadName ?? 'N/A'}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6),
                                          Text(
                                              "${localizations.date}: ${r.date ?? 'N/A'}"),
                                          Text(
                                              "${localizations.address}: ${r.address ?? 'N/A'}"),
                                          Text(
                                              "${localizations.pinCode}: ${r.city ?? ''}, ${r.pinCode ?? ''}"),
                                          Text(
                                              "${localizations.phone}: ${r.mobileNumber ?? 'N/A'}"),
                                          Text(
                                              "${_boolToText(r.eenaduNewspaper)}"),
                                          Text(
                                              "${localizations.employed}: ${_boolToText(r.employed)}"),
                                          Text(
                                              "${localizations.agentName}: ${r.agentName ?? 'N/A'}"),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Location URL: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    openGoogleMaps(
                                                      double.tryParse(
                                                          r.latitude ?? ''),
                                                      double.tryParse(
                                                          r.longitude ?? ''),
                                                      r.locationUrl,
                                                    );
                                                  },
                                                  child: Text(
                                                    r.locationUrl != null &&
                                                            r.locationUrl !=
                                                                'false' &&
                                                            r.locationUrl !=
                                                                'N/A'
                                                        ? r.locationUrl!
                                                        : 'View on Google Maps',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                      //decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (r.faceBase64 != null &&
                                              r.faceBase64!.isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  " land mark",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 6),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    base64Decode(_cleanBase64(
                                                        r.faceBase64!)),
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Text(
                                                            "Invalid image"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
