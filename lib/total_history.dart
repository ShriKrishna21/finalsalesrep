import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class totalHistory {
  Future<Historymodel?> fetchCustomerForm() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    final userid = prefs.getInt('id');

    if (apikey == null || userid == null) {
      print("Missing user credentials: apiKey=$apikey, userId=$userid");
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse(CommonApiClass.totalHistory),
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

        await prefs.setInt(
          'record_count',
          historyData.result?.records?.length ?? 0,
        );

        print("Fetched Records: ${historyData.result?.records?.length}");
        return historyData;
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
