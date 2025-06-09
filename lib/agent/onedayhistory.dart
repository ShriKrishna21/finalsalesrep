import 'dart:convert';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Onedayhistory extends StatefulWidget {
  const Onedayhistory({super.key});

  @override
  State<Onedayhistory> createState() => _OnedayhistoryState();
}

class _OnedayhistoryState extends State<Onedayhistory> {
  OneDayHistory? onedayforms;
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchOnedayHistory();
  }

  Future<void> fetchOnedayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print("Missing user credentials");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse("http://10.100.13.138:8099/api/customer_forms_info_one_day"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "user_id": userid,
                "token": apikey,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        final jsonResponse = jsonDecode(response.body);
        final historyoneday = OneDayHistory.fromJson(jsonResponse);
        final records = historyoneday.result?.records ?? [];

        int accepted = 0;
        int rejected = 0;
        int subscribed = 0;

        for (var record in records) {
          if (record.eenaduNewspaper == true) {
            subscribed++;
            continue; // Skip offer check if already subscribed
          }

          if (record.freeOffer15Days == true) {
            accepted++;
          }

          if (record.reasonNotTakingOffer != null &&
              record.reasonNotTakingOffer!.isNotEmpty) {
            rejected++;
          }
        }

        await prefs.setInt('today_count', records.length);
        await prefs.setInt('offer_accepted', accepted);
        await prefs.setInt('offer_rejected', rejected);
        await prefs.setInt('already_subscribed', subscribed);

        print("Saved today_count = ${records.length}");
        print("Offer Accepted: $accepted, Rejected: $rejected, Subscribed: $subscribed");

        setState(() {
          onedayforms = historyoneday;
          _isLoading = false;
          offerAcceptedCount = accepted;
          offerRejectedCount = rejected;
          alreadySubscribedCount = subscribed;
        });
      } else {
        print("Failed to fetch one-day history: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching one-day history: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ondayCustomerData = onedayforms?.result?.records ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Houses Visited Today"),
            const Spacer(),
            Text("count: ${ondayCustomerData.length}"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ondayCustomerData.isEmpty
              ? const Center(child: Text("No Houses Visited Today"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(" Offer Accepted: $offerAcceptedCount"),
                          Text(" Offer Rejected: $offerRejectedCount"),
                          Text(" Already Subscribed: $alreadySubscribedCount"),
                          const Divider(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ondayCustomerData.length,
                        itemBuilder: (context, index) {
                          final record = ondayCustomerData[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("Record ID: ${record.id ?? "N/A"}"),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Agent Name: ${record.agentName ?? 'N/A'}",
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Agent Login: ${record.agentLogin ?? 'N/A'}"),
                                    Text("Date: ${record.date ?? 'N/A'}"),
                                    Text("Time: ${record.time ?? 'N/A'}"),
                                    Text("Family Head Name: ${record.familyHeadName ?? 'N/A'}"),
                                    Text("Father Name: ${record.fatherName ?? 'N/A'}"),
                                    Text("Mother Name: ${record.motherName ?? 'N/A'}"),
                                    Text("Spouse Name: ${record.spouseName ?? 'N/A'}"),
                                    Text("House Number: ${record.houseNumber ?? 'N/A'}"),
                                    Text("Street Number: ${record.streetNumber ?? 'N/A'}"),
                                    Text("City: ${record.city ?? 'N/A'}"),
                                    Text("Pin Code: ${record.pinCode ?? 'N/A'}"),
                                    Text("Address: ${record.address ?? 'N/A'}"),
                                    Text("Mobile Number: ${record.mobileNumber ?? 'N/A'}"),
                                    Text("Eenadu Newspaper: ${record.eenaduNewspaper ?? 'N/A'}"),
                                    Text("Feedback to Improve: ${record.feedbackToImproveEenaduPaper ?? 'N/A'}"),
                                    Text("Read Newspaper: ${record.readNewspaper ?? 'N/A'}"),
                                    Text("Current Newspaper: ${record.currentNewspaper ?? 'N/A'}"),
                                    Text("Reason for not taking Eenadu: ${record.reasonForNotTakingEenaduNewsPaper ?? 'N/A'}"),
                                    Text("Reason not reading: ${record.reasonNotReading ?? 'N/A'}"),
                                    Text("Free Offer 15 Days: ${record.freeOffer15Days ?? 'N/A'}"),
                                    Text("Reason not taking offer: ${record.reasonNotTakingOffer ?? 'N/A'}"),
                                    Text("Employed: ${record.employed ?? 'N/A'}"),
                                    Text("Job Type: ${record.jobType ?? 'N/A'}"),
                                    Text("Job Type One: ${record.jobTypeOne ?? 'N/A'}"),
                                    Text("Job Profession: ${record.jobProfession ?? 'N/A'}"),
                                    Text("Job Designation: ${record.jobDesignation ?? 'N/A'}"),
                                    Text("Company Name: ${record.companyName ?? 'N/A'}"),
                                    Text("Profession: ${record.profession ?? 'N/A'}"),
                                    Text("Job Working State: ${record.jobWorkingState ?? 'N/A'}"),
                                    Text("Job Working Location: ${record.jobWorkingLocation ?? 'N/A'}"),
                                    Text("Job Designation One: ${record.jobDesignationOne ?? 'N/A'}"),
                                    Text("Latitude: ${record.latitude ?? 'N/A'}"),
                                    Text("Longitude: ${record.longitude ?? 'N/A'}"),
                                    Text("Location Address: ${record.locationAddress ?? 'N/A'}"),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
