import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Allcustomerforms extends StatefulWidget {
  const Allcustomerforms({super.key});

  @override
  State<Allcustomerforms> createState() => _AllcustomerformsState();
}

class _AllcustomerformsState extends State<Allcustomerforms> {
  List<Record> records = [];
  List<Record> filteredRecords = [];

  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
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

    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/customer_forms_filtered'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = AllCustomerForms.fromJson(jsonDecode(response.body));
        final fetchedRecords = (data.result?.records ?? []).reversed.toList();

        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in fetchedRecords) {
          if (record.eenaduNewspaper == true) {
            subscribed++;
          } else if (record.freeOffer15Days == true) {
            accepted++;
          } else if (record.freeOffer15Days == false &&
              record.eenaduNewspaper == false) {
            rejected++;
          }
        }

        setState(() {
          records = fetchedRecords;
          filteredRecords = fetchedRecords;
          alreadySubscribedCount = subscribed;
          offerAcceptedCount = accepted;
          offerRejectedCount = rejected;
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
    }
  }

  String _boolToText(bool? value) {
    final localizations = AppLocalizations.of(context)!;
    if (value == null) return 'N/A';
    return value ? localizations.yes : localizations.no;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
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
                          // hintText: localizations.searchbynameoridormobilenumber,git
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
                            Text(
                                " ${localizations.daysOfferRejected15}: $offerRejectedCount"),
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
                                              "${localizations.eenadunewspaper}: ${_boolToText(r.eenaduNewspaper)}"),
                                          Text(
                                              "${localizations.employed}: ${_boolToText(r.employed)}"),
                                          Text(
                                              "${localizations.agentName}: ${r.agentName ?? 'N/A'}"),
                                          Text(
                                              "${localizations.daysforeenaduoffer}: ${_boolToText(r.freeOffer15Days)}"),
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

class AllCustomerForms {
  String? jsonrpc;
  dynamic id;
  Result? result;

  AllCustomerForms({this.jsonrpc, this.id, this.result});

  factory AllCustomerForms.fromJson(Map<String, dynamic> json) {
    return AllCustomerForms(
      jsonrpc: json['jsonrpc'],
      id: json['id'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  bool? success;
  List<Record>? records;
  int? count;
  String? code;

  Result({this.success, this.records, this.count, this.code});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      success: json['success'],
      records:
          (json['records'] as List?)?.map((e) => Record.fromJson(e)).toList(),
      count: json['count'],
      code: json['code'],
    );
  }
}

class Record {
  int? id;
  String? familyHeadName;
  String? agentName;
  String? date;
  String? address;
  String? city;
  String? pinCode;
  String? mobileNumber;
  bool? eenaduNewspaper;
  bool? employed;
  bool? freeOffer15Days;

  Record({
    this.id,
    this.familyHeadName,
    this.agentName,
    this.date,
    this.address,
    this.city,
    this.pinCode,
    this.mobileNumber,
    this.eenaduNewspaper,
    this.employed,
    this.freeOffer15Days,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      familyHeadName: json['family_head_name'],
      agentName: json['agent_name'],
      date: json['date'],
      address: json['address'],
      city: json['city'],
      pinCode: json['pin_code'],
      mobileNumber: json['mobile_number'],
      eenaduNewspaper: _parseBool(json['eenadu_newspaper']),
      employed: _parseBool(json['employed']),
      freeOffer15Days: _parseBool(json['free_offer_15_days']),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return null;
  }
}
