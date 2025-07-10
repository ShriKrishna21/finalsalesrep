import 'dart:convert';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class customerformsunit extends StatefulWidget {
  final String unitName;

  const customerformsunit({super.key, required this.unitName});

  @override
  State<customerformsunit> createState() => _customerformsunitState();
}

class _customerformsunitState extends State<customerformsunit> {
  List<Record> records = [];
  bool isLoading = true;
  int eenaduCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllForms();
  }

  Future<void> fetchAllForms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    final unitName = widget.unitName;

    print("🔑 Token: $token");
    print("🏢 Unit Name (from nav): $unitName");

    if (token == null || unitName.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Missing token or unit name';
      });
      return;
    }

    final requestBody = {
      "params": {
        "token": token,
        "from_date": "",
        "to_date": "",
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
        final fetchedRecords = data.result?.records ?? [];

        setState(() {
          records = fetchedRecords;
          eenaduCount = fetchedRecords
              .where((r) => _parseBool(r.eenaduNewspaper) == true)
              .length;
          offerAcceptedCount = fetchedRecords
              .where((r) => _parseBool(r.freeOffer15Days) == true)
              .length;
          offerRejectedCount = fetchedRecords
              .where((r) => _parseBool(r.freeOffer15Days) == false)
              .length;
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

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return null;
  }

  String _boolToText(bool? value) {
    if (value == null) return 'N/A';
    return value ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("Customer Forms - ${widget.unitName}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text("⚠️ $errorMessage"))
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Summary",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text("Eenadu Subscription: $eenaduCount"),
                            Text("Offer Accepted: $offerAcceptedCount"),
                            Text("Offer Rejected: $offerRejectedCount"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: records.isEmpty
                          ? const Center(
                              child: Text("No customer forms available."))
                          : ListView.builder(
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final r = records[index];
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
                                          "Family Head: ${r.familyHeadName ?? 'N/A'}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text("Date: ${r.date ?? 'N/A'}"),
                                        Text("Address: ${r.address ?? 'N/A'}"),
                                        Text(
                                            "City & Pincode: ${r.city ?? ''}, ${r.pinCode ?? ''}"),
                                        Text(
                                            "Mobile: ${r.mobileNumber ?? 'N/A'}"),
                                        Text(
                                            "Reads Eenadu: ${_boolToText(_parseBool(r.eenaduNewspaper))}"),
                                        Text(
                                            "Employed: ${_boolToText(_parseBool(r.employed))}"),
                                        Text(
                                            "Agent Name: ${r.agentName ?? 'N/A'}"),
                                        Text(
                                            "Offer: ${_boolToText(_parseBool(r.freeOffer15Days))}"),
                                        // Text(
                                        //     "unit: ${_boolToText(_parseBool(r.unitName))}"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
    );
  }
}
