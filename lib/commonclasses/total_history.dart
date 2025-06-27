import 'dart:convert';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TotalHistory {
  Future<Map<String, Object>?> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print("Missing user credentials: apiKey=$apikey, userId=$userid");
      return null;
    }

    try {
      print(
          "📍 Calling API at https://salesrep.esanchaya.com/api/customer_forms_info_id with userId=$userid");

      final response = await http
          .post(
            Uri.parse(
                "https://salesrep.esanchaya.com/api/customer_forms_info_id"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "user_id": userid.toString(), // Ensure it's a string
                "token": apikey,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final historyData = Historymodel.fromJson(jsonResponse);
        final records = historyData.result?.records ?? [];

        int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        for (var record in records) {
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

        await prefs.setInt('today_count', records.length);
        await prefs.setInt('offer_accepted', accepted);
        await prefs.setInt('offer_rejected', rejected);
        await prefs.setInt('already_subscribed', subscribed);

        return {
          'records': records,
          'offer_accepted': accepted,
          'offer_rejected': rejected,
          'already_subscribed': subscribed,
        };
      } else {
        print("❌ API Error: ${response.statusCode} ${response.reasonPhrase}");
        return null;
      }
    } catch (error) {
      print("❌ Fetch error: $error");
      return null;
    }
  }
}
