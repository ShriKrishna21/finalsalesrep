import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Allcustomerforms extends StatefulWidget {
  const Allcustomerforms({super.key});

  @override
  State<Allcustomerforms> createState() => _AllcustomerformsState();
}

class _AllcustomerformsState extends State<Allcustomerforms> {
  List<Record> records = [];
  bool isLoading = true;
  int eenaduCount = 0;
  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAllForms();
  }

  Future<void> fetchAllForms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit_name');

    if (token == null || unitName == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://salesrep.esanchaya.com/api/customer_forms_filtered'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": token,
            "from_date": "",
            "to_date": "",
            "unit_name": unitName,
            "agent_name": "",
            "order": "asc",
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = AllCustomerForms.fromJson(jsonDecode(response.body));
        final fetchedRecords = data.result?.records ?? [];

        setState(() {
          records = fetchedRecords;
          eenaduCount =
              fetchedRecords.where((r) => r.eenaduNewspaper == true).length;
          offerAcceptedCount =
              fetchedRecords.where((r) => r.offerAccepted == true).length;
          offerRejectedCount =
              fetchedRecords.where((r) => r.offerAccepted == false).length;
          isLoading = false;
        });
      } else {
        print("❌ Error: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("All Customer Forms"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        const Text("📊 Summary",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text("🗞️ Eenadu Subscription: $eenaduCount"),
                        Text("✅ Offer Accepted: $offerAcceptedCount"),
                        Text("❌ Offer Rejected: $offerRejectedCount"),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "👤 Family Head: ${r.familyHeadName ?? 'N/A'}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text("📅 Date: ${r.date ?? 'N/A'}"),
                                    Text("📍 Address: ${r.address ?? 'N/A'}"),
                                    Text(
                                        "🏙️ City & Pincode: ${r.city ?? ''}, ${r.pinCode ?? ''}"),
                                    Text(
                                        "📞 Mobile: ${r.mobileNumber ?? 'N/A'}"),
                                    Text(
                                        "📰 Reads Eenadu: ${r.eenaduNewspaper == true ? 'Yes' : 'No'}"),
                                    Text(
                                        "💼 Employed: ${r.employed == true ? 'Yes' : 'No'}"),
                                    Text(
                                        "💼 Agent Name: ${r.agentName ?? 'N/A'}"),
                                    Text(
                                        "🤝 Offer: ${r.offerAccepted == null ? 'N/A' : r.offerAccepted == true ? 'Yes' : 'No'}"),
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
  List<Record>? records;

  Result({this.records});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      records:
          (json['records'] as List?)?.map((e) => Record.fromJson(e)).toList(),
    );
  }
}

class Record {
  String? familyHeadName;
  String? date;
  String? address;
  String? city;
  String? pinCode;
  String? mobileNumber;
  bool? eenaduNewspaper;
  bool? employed;
  String? agentName;
  bool? offerAccepted;

  Record({
    this.familyHeadName,
    this.date,
    this.address,
    this.city,
    this.pinCode,
    this.mobileNumber,
    this.eenaduNewspaper,
    this.employed,
    this.agentName,
    this.offerAccepted,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      familyHeadName: json['family_head_name'],
      date: json['date'],
      address: json['address'],
      city: json['city'],
      pinCode: json['pin_code'],
      mobileNumber: json['mobile_number'],
      eenaduNewspaper: json['eenadu_newspaper'],
      employed: json['employed'],
      agentName: json['agent_name'],
      offerAccepted: json['offeraccepted'],
    );
  }
}
