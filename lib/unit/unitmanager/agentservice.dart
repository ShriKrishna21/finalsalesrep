import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AgentService {
  static Future<int> fetchAgentCountFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (apiKey == null || unitName == null || unitName.isEmpty) {
      print("❌ API Key or Unit Name is missing");
      return 0;
    }

    try {
      final response = await http
          .post(
            Uri.parse(CommonApiClass.agentUnitWise),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "token": apiKey,
                "unit_name": unitName,
              }
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> users = jsonResponse['result']['users'];
        return users.length;
      } else {
        print("❌ Failed to fetch agent count. Status: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("❌ Exception in fetching agent count: $e");
      return 0;
    }
  }
}
