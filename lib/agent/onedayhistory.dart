import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';

class Onedayhistory extends StatefulWidget {
  const Onedayhistory({super.key});

  @override
  State<Onedayhistory> createState() => _OnedayhistoryState();
}

class _OnedayhistoryState extends State<Onedayhistory> {
  List<Record> records = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();

  @override
  void initState() {
    super.initState();
    loadOnedayHistory();
  }

Future<void> loadOnedayHistory() async {
  setState(() {
    _isLoading = true;
  });

  final result = await _onedayagent.fetchOnedayHistory();

  setState(() {
    records = (result['records'] as List<Record>?) ?? [];

    offerAcceptedCount = result['offer_accepted'] ?? 0;
    offerRejectedCount = result['offer_rejected'] ?? 0;
    alreadySubscribedCount = result['already_subscribed'] ?? 0;
    _isLoading = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Houses Visited Today"),
            const Spacer(),
            Text("count: ${records.length}"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No Houses Visited Today"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Offer Accepted: $offerAcceptedCount"),
                          Text("Offer Rejected: $offerRejectedCount"),
                          Text("Already Subscribed: $alreadySubscribedCount"),
                          const Divider(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("Record ID: ${record.id ?? "N/A"}"),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Agent Name: ${record.agentName ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
