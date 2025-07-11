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
  bool isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllForms();
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

        // Custom logic for count
        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in fetchedRecords) {
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

        setState(() {
          records = fetchedRecords;
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
    if (value == null) return 'N/A';
    return value ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(Localizations.viewallcustomerforms),
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
                            Text(Localizations.summary,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                                "${Localizations.eenaduSubscription} $alreadySubscribedCount"),
                            Text(
                                "${Localizations.daysOfferAccepted15} $offerAcceptedCount"),
                            Text(
                                "${Localizations.daysOfferRejected15} $offerRejectedCount"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: records.isEmpty
                          ? Center(
                              child:
                                  Text(Localizations.nocustomerformsavailable))
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
                                          "${Localizations.familyheadname}: ${r.familyHeadName ?? 'N/A'}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${Localizations.date}: ${r.date ?? 'N/A'}",
                                        ),
                                        Text(
                                          "${Localizations.address}: ${r.address ?? 'N/A'}",
                                        ),
                                        Text(
                                          "${Localizations.pinCode}: ${r.city ?? ''}, ${r.pinCode ?? ''}",
                                        ),
                                        Text(
                                          "${Localizations.mobilenumber}: ${r.mobileNumber ?? 'N/A'}",
                                        ),
                                        Text(
                                          "${Localizations.readnewspaper}: ${_boolToText(r.eenaduNewspaper)}",
                                        ),
                                        Text(
                                          "${Localizations.employed}: ${_boolToText(r.employed)}",
                                        ),
                                        Text(
                                          "${Localizations.agentName}: ${r.agentName ?? 'N/A'}",
                                        ),
                                        Text(
                                          "${Localizations.offer}: ${_boolToText(r.freeOffer15Days)}",
                                        ),
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

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'result': result?.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'records': records?.map((e) => e.toJson()).toList(),
      'count': count,
      'code': code,
    };
  }
}

class Record {
  int? id;
  String? agentName;
  String? agentLogin;
  String? unitName;
  String? date;
  String? time;
  String? familyHeadName;
  String? fatherName;
  String? motherName;
  String? spouseName;
  String? houseNumber;
  String? streetNumber;
  String? city;
  String? pinCode;
  String? address;
  String? mobileNumber;
  bool? eenaduNewspaper;
  String? feedbackToImproveEenaduPaper;
  bool? readNewspaper;
  String? currentNewspaper;
  String? reasonForNotTakingEenaduNewsPaper;
  String? reasonNotReading;
  bool? freeOffer15Days;
  String? reasonNotTakingOffer;
  bool? employed;
  bool? jobType;
  bool? jobTypeOne;
  String? jobProfession;
  String? jobDesignation;
  String? companyName;
  String? profession;
  bool? jobWorkingState;
  bool? jobWorkingLocation;
  String? jobDesignationOne;
  String? latitude;
  String? longitude;
  String? locationAddress;
  bool? offerAccepted;

  Record({
    this.id,
    this.agentName,
    this.agentLogin,
    this.unitName,
    this.date,
    this.time,
    this.familyHeadName,
    this.fatherName,
    this.motherName,
    this.spouseName,
    this.houseNumber,
    this.streetNumber,
    this.city,
    this.pinCode,
    this.address,
    this.mobileNumber,
    this.eenaduNewspaper,
    this.feedbackToImproveEenaduPaper,
    this.readNewspaper,
    this.currentNewspaper,
    this.reasonForNotTakingEenaduNewsPaper,
    this.reasonNotReading,
    this.freeOffer15Days,
    this.reasonNotTakingOffer,
    this.employed,
    this.jobType,
    this.jobTypeOne,
    this.jobProfession,
    this.jobDesignation,
    this.companyName,
    this.profession,
    this.jobWorkingState,
    this.jobWorkingLocation,
    this.jobDesignationOne,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.offerAccepted,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      agentName: json['agent_name'],
      agentLogin: json['agent_login'],
      unitName: json['unit_name'],
      date: json['date'],
      time: json['time'],
      familyHeadName: json['family_head_name'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      spouseName: json['spouse_name'],
      houseNumber: json['house_number'],
      streetNumber: json['street_number'],
      city: json['city'],
      pinCode: json['pin_code'],
      address: json['address'],
      mobileNumber: json['mobile_number'],
      eenaduNewspaper: _parseBool(json['eenadu_newspaper']),
      feedbackToImproveEenaduPaper: json['feedback_to_improve_eenadu_paper'],
      readNewspaper: _parseBool(json['read_newspaper']),
      currentNewspaper: json['current_newspaper'],
      reasonForNotTakingEenaduNewsPaper:
          json['reason_for_not_taking_eenadu_newsPaper'],
      reasonNotReading: json['reason_not_reading'],
      freeOffer15Days: _parseBool(json['free_offer_15_days']),
      reasonNotTakingOffer: json['reason_not_taking_offer'],
      employed: _parseBool(json['employed']),
      jobType: _parseBool(json['job_type']),
      jobTypeOne: _parseBool(json['job_type_one']),
      jobProfession: json['job_profession'],
      jobDesignation: json['job_designation'],
      companyName: json['company_name'],
      profession: json['profession'],
      jobWorkingState: _parseBool(json['job_working_state']),
      jobWorkingLocation: _parseBool(json['job_working_location']),
      jobDesignationOne: json['job_designation_one'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationAddress: json['location_address'],
      offerAccepted: _parseBool(json['offeraccepted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_name': agentName,
      'agent_login': agentLogin,
      'unit_name': unitName,
      'date': date,
      'time': time,
      'family_head_name': familyHeadName,
      'father_name': fatherName,
      'mother_name': motherName,
      'spouse_name': spouseName,
      'house_number': houseNumber,
      'street_number': streetNumber,
      'city': city,
      'pin_code': pinCode,
      'address': address,
      'mobile_number': mobileNumber,
      'eenadu_newspaper': eenaduNewspaper,
      'feedback_to_improve_eenadu_paper': feedbackToImproveEenaduPaper,
      'read_newspaper': readNewspaper,
      'current_newspaper': currentNewspaper,
      'reason_for_not_taking_eenadu_newsPaper':
          reasonForNotTakingEenaduNewsPaper,
      'reason_not_reading': reasonNotReading,
      'free_offer_15_days': freeOffer15Days,
      'reason_not_taking_offer': reasonNotTakingOffer,
      'employed': employed,
      'job_type': jobType,
      'job_type_one': jobTypeOne,
      'job_profession': jobProfession,
      'job_designation': jobDesignation,
      'company_name': companyName,
      'profession': profession,
      'job_working_state': jobWorkingState,
      'job_working_location': jobWorkingLocation,
      'job_designation_one': jobDesignationOne,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'offeraccepted': offerAccepted,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return null;
  }
}
