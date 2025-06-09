import 'dart:convert';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
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
    fetchCustomerForm();
  }

  Future<void> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print(apikey);
      print(userid);
      print("Missing user credentials");

    }

    // const url = "http://10.100.13.138:8099/api/customer_forms_info_id";

    try {
      final response = await http
          .post(
            Uri.parse("http://10.100.13.138:8099/api/customer_forms_info_id"),
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
        final jsonResponse = jsonDecode(response.body);
        final historyData = Historymodel.fromJson(jsonResponse);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            'record_count', historyData.result?.records?.length ?? 0);


            print("ggggggggggggggggg${historyData.result?.records?.length}");
        print("Response: $jsonResponse");

        setState(() {
          //  customerFormData=jsonResponse;
          forms = historyData;
          print("y1111111111111111111111111111111111111$forms");
          print("History Data: ${historyData.result?.records}");
          // Update the state with the fetched data
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Fetch error: $error");
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
