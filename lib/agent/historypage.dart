import 'dart:convert';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:finalsalesrep/total_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  Map<String, dynamic>? customerFormData;
  Historymodel? forms;
  List<dynamic> historyRecords = [];
  @override
  void initState() {
    super.initState();
   // fetchCustomerForm();
   loadTotalHistory();
  }
void loadTotalHistory()async{
  totalHistory historyFetcher=totalHistory();
  Historymodel? historyData=await historyFetcher.fetchCustomerForm();
  if(historyData!=null){
    setState(() {
      forms=historyData;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final coustmerdata = forms?.result?.records ?? [];

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          const Text("History"),
          Spacer(),
          Text("Total Records: ${coustmerdata.length}"),
        ],
      )),
      body: coustmerdata.isEmpty
          ? const Center(child: Text("No Records Found"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: coustmerdata.length,
              itemBuilder: (context, index) {
                final record = coustmerdata[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("record id: ${record.id ?? 'N/A'}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Agent Name: ${record.agentName ?? 'N/A'}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Agent login : ${record.agentLogin ?? 'N/A'}"),
                        Text("Date: ${record.date ?? 'N/A'}"),
                        Text("time: ${record.time ?? 'N/A'}"),
                        Text(
                            "familyheadname: ${record.familyHeadName ?? 'N/A'}"),
                        Text("fathername: ${record.fatherName ?? 'N/A'}"),
                        Text("mother_name: ${record.motherName ?? 'N/A'}"),
                        Text("house_number: ${record.houseNumber ?? 'N/A'}"),
                        Text("street_number: ${record.streetNumber ?? 'N/A'}"),
                        Text("City: ${record.city ?? 'N/A'}"),
                        Text("pin_code: ${record.pinCode ?? 'N/A'}"),
                        Text("address: ${record.address ?? 'N/A'}"),
                        Text("Mobile: ${record.mobileNumber ?? 'N/A'}"),
                        Text(
                            "eenadu_newspaper: ${record.eenaduNewspaper ?? 'N/A'}"),

                        Text(
                            "current_newspaper: ${record.currentNewspaper ?? 'N/A'}"),
                        Text(
                            "reason_for_not_taking_eenadu_newsPaper: ${record.reasonForNotTakingEenaduNewsPaper ?? 'N/A'}"),
                        Text(
                            "reason_not_reading: ${record.reasonNotReading ?? 'N/A'}"),
                        Text("offer : ${record.freeOffer15Days ?? 'N/A'}"),
                        Text(
                            "reason for not taking offer : ${record.reasonNotTakingOffer ?? 'N/A'}"),
                        Text("employed: ${record.employed ?? 'N/A'}"),
                        Text("job_type: ${record.jobType ?? 'N/A'}"),
                        Text("job_type_one : ${record.jobTypeOne ?? 'N/A'}"),
                        Text(
                            "job_profession: ${record.jobProfession ?? 'N/A'}"),
                        Text(
                            "job_designation: ${record.jobDesignation ?? 'N/A'}"),

                        Text("companyname: ${record.companyName ?? 'N/A'}"),

                        Text("proffesion: ${record.profession ?? 'N/A'}"),

                        Text(
                            "job_working_state: ${record.jobWorkingState ?? 'N/A'}"),

                        Text(
                            "jobWorkingLocation : ${record.jobWorkingLocation ?? 'N/A'}"),
                        Text(
                            "job_designation_one: ${record.jobDesignationOne ?? 'N/A'}"),

                        Text("latitude : ${record.latitude ?? 'N/A'}"),
                        Text("longitude: ${record.longitude ?? 'N/A'}"),
                        Text(
                            "location_address: ${record.locationAddress ?? 'N/A'}"),

                        // Add more fields here if needed
                      ],
                    ),
                  ),
                );
              },
            ),
            
    );
  }
}
