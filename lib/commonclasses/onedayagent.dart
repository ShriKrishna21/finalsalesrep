import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Onedayagent {
  Future<Map<String, dynamic>> fetchOnedayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print("❌ Missing user credentials: apikey or id is null");
      return {'error': 'Missing credentials'};
    }

    final apiUrl = CommonApiClass.oneDayAgent;

    print("📡 Hitting API: $apiUrl");
    print("📦 Payload: ${jsonEncode({
      "params": {
        "user_id": userid,
        "token": apikey,
      }
    })}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "user_id": userid,
            "token": apikey,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      print("🔁 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Response: $jsonResponse");

        final historyoneday = OneDayHistory.fromJson(jsonResponse);
        final records = historyoneday.result?.records ?? [];

        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in records) {
          final isSubscribed = record.eenaduNewspaper == true;
          final isAccepted = record.freeOffer15Days == true;
          final isRejected = record.freeOffer15Days == false;

          if (isSubscribed) {
            subscribed++;
          } else {
            if (isAccepted) accepted++;
            if (isRejected) rejected++;
          }
        }

        print("📊 Final Counts → Subscribed: $subscribed, Accepted: $accepted, Rejected: $rejected");

        // Save locally
        await prefs.setInt('today_count', records.length);
        await prefs.setInt('offer_accepted', accepted);
        await prefs.setInt('offer_rejected', rejected);
        await prefs.setInt('already_subscribed', subscribed);

        print("✅ Saved all counts to SharedPreferences");

        return {
          'records': records,
          'offer_accepted': accepted,
          'offer_rejected': rejected,
          'already_subscribed': subscribed,
        };
      } else {
        print("❌ Server returned error: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return {'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print("❌ Network/Parsing error: $e");
      return {'error': 'Network or unexpected error'};
    }
  }
}
