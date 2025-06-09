import 'dart:convert';

import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class Historyprovider extends ChangeNotifier{
  Historymodel? totaldat;

Future<void> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print(apikey);
      print(userid);
      print("Missing user credentials");
      return;
    }

    const url = "http://10.100.13.138:8099/api/customer_forms_info_id";

    try {
      final response = await http
          .post(
            Uri.parse(url),
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

        
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Fetch error: $error");
    }
  }


}