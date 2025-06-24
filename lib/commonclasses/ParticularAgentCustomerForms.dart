import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/ParticularAgentCustomerForms.dart'
    show ParticularAgentCustomerForms;
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart'
    show ParticularAgentCustomerForms;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParticularAgentCustomerFormsService {
  Future<ParticularAgentCustomerForms?> fetchCustomerForms() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (apiKey == null || userId == null) {
      print("Missing credentials: apiKey=$apiKey, userId=$userId");
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse(CommonApiClass.customerform),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "user_id": userId,
                "token": apiKey,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final result = ParticularAgentCustomerForms.fromJson(data);

        final recordCount = result.result?.records?.length ?? 0;
        await prefs.setInt('record_count', recordCount);

        print("Fetched ${recordCount} customer forms.");
        return result;
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return null;
    }
  }
}
