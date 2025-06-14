import 'dart:convert';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class totalHistory {
  Future<Map<String, Object>?> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print("Missing user credentials: apiKey=$apikey, userId=$userid");
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.100.13.138:8099/api/customer_forms_info_id"),
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
        final historyData = Historymodel.fromJson(jsonResponse);
  final records = historyData.result?.records ?? [];

  int subscribed = 0;
        int accepted = 0;
        int rejected = 0;

        print('--- Starting record processing ---');

        for (var record in records) {
          
          print('\nProcessing record: $record');

          if (record.eenaduNewspaper == true) {
        
            subscribed++;
            print(
                '  -> eenaduNewspaper is TRUE. Incremented subscribed. Current subscribed: $subscribed');
          } else {
            // If not subscribed to Eenadu Newspaper, then evaluate offer acceptance/rejection
            print('  -> eenaduNewspaper is FALSE. Checking offer status...');

            if (record.freeOffer15Days == true) {
              accepted++;
              print(
                  '    -> freeOffer15Days is TRUE. Incremented accepted. Current accepted: $accepted');
            }

            // Only count as rejected if a reason is present AND eenaduNewspaper is false (which is handled by the 'else' block)
            if (record.freeOffer15Days == false&&record.eenaduNewspaper == false) {
              rejected++;
              print(
                  '    -> reasonNotTakingOffer is NOT empty. Incremented rejected. Current rejected: $rejected');
            } else {
              print('    -> reasonNotTakingOffer is empty or null.');
            }
          }
          print(
              '  --- Current Counts: Subscribed: $subscribed, Accepted: $accepted, Rejected: $rejected ---');
        }

        print('\n--- Processing complete ---');
        await prefs.setInt('today_count', records.length);
        print('Saved today_count: ${records.length}');

        await prefs.setInt('offer_accepted', accepted);
        print('Saved offer_accepted: $accepted');

        await prefs.setInt('offer_rejected', rejected);
        print('Saved offer_rejected: $rejected');

        await prefs.setInt('already_subscribed', subscribed);
        print('Saved already_subscribed: $subscribed');

        print('--- All counts saved to SharedPreferences ---');

        print(
            "Offer Accepted: $accepted, Rejected: $rejected, Subscribed: $subscribed");

        return {
          'records': records,
          'offer_accepted': accepted,
          'offer_rejected': rejected,
          'already_subscribed': subscribed,
        };;
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Fetch error: $error");
      return null;
    }
  }
}
