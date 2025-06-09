import 'dart:convert';

import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Onedayagent {
  Future<Map<String, dynamic>> fetchOnedayHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final apikey = prefs.getString('apikey');
  final userid = prefs.getInt('id');

  if (apikey == null || userid == null) {
    print("Missing user credentials");
    return {};
  }

  try {
    final response = await http.post(
      Uri.parse("http://10.100.13.138:8099/api/customer_forms_info_one_day"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {
          "user_id": userid,
          "token": apikey,
        }
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final historyoneday = OneDayHistory.fromJson(jsonResponse);
      final records = historyoneday.result?.records ?? [];

      int accepted = 0;
      int rejected = 0;
      int subscribed = 0;

      for (var record in records) {
        if (record.eenaduNewspaper == true) {
          subscribed++;
          continue;
        }
        if (record.freeOffer15Days == true) accepted++;
        if (record.reasonNotTakingOffer?.isNotEmpty == true) rejected++;
      }

      await prefs.setInt('today_count', records.length);
      await prefs.setInt('offer_accepted', accepted);
      await prefs.setInt('offer_rejected', rejected);
      await prefs.setInt('already_subscribed', subscribed);

      print("Offer Accepted: $accepted, Rejected: $rejected, Subscribed: $subscribed");

      return {
        'records': records,
        'offer_accepted': accepted,
        'offer_rejected': rejected,
        'already_subscribed': subscribed,
      };
    } else {
      print("Failed with status code: ${response.statusCode}");
      print("Body: ${response.body}");
      return {};
    }
  } catch (error) {
    print("Error: $error");
    return {};
  }
}
}