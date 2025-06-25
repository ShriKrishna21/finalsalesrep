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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Houses Visited Today",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(
                  child: Text("No Houses Visited Today"),
                )
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildRecordTile(record);
                  },
                ),
    );
  }

  Widget _buildRecordTile(Record record) {
    return ExpansionTile(
      title: Text(
        record.familyHeadName != null
            ? "Family Head: ${record.familyHeadName}"
            : "No Name",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetail("Agent Name", record.agentName),
              _buildDetail("Agent Login", record.agentLogin),
              _buildDetail("Date", record.date),
              _buildDetail("Time", record.time),
              _buildDetail("Father Name", record.fatherName),
              _buildDetail("Mother Name", record.motherName),
              _buildDetail("Spouse Name", record.spouseName),
              _buildDetail("Eenadu Newspaper", "${record.eenaduNewspaper}"),
              _buildDetail("Feedback", record.feedbackToImproveEenaduPaper),
              _buildDetail(
                        "Read Newspaper", "${record.readNewspaper ?? 'N/A'}"),
              _buildDetail("Current Newspaper", record.currentNewspaper),
              _buildDetail("Reason Not Taking Eenadu", record.reasonForNotTakingEenaduNewsPaper),
              _buildDetail("Reason Not Reading", record.reasonNotReading),
              _buildDetail("Reason Not Taking Offer", record.reasonNotTakingOffer),
              _buildDetail("Employed", "${record.employed ?? 'N/A'}"),
              _buildDetail("Job Type", record.jobType),
              _buildDetail("Job Profession", record.jobProfession),
              _buildDetail("Company Name", record.companyName),
              _buildDetail("Profession", record.profession),
              _buildDetail("Job Working State", record.jobWorkingState),
              _buildDetail("Working Location", record.jobWorkingLocation),
              _buildDetail("Designation", record.jobDesignationOne),
              _buildDetail("Latitude", record.latitude),
              _buildDetail("Longitude", record.longitude),
              _buildDetail("House No.", record.houseNumber),
              _buildDetail("Street No.", record.streetNumber),
              _buildDetail("City", record.city),
              _buildDetail("Pin Code", record.pinCode),
              _buildDetail("Address", record.address),
              _buildDetail("Mobile Number", record.mobileNumber),
              _buildDetail("Location Address", record.locationAddress),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text("$label: ${value ?? 'N/A'}",
          style: const TextStyle(fontSize: 15)),
    );
  }
}
