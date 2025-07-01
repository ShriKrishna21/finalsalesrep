import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart' show NofAgents, User;

class NoOfAgentsService {
  Future<List<User>> fetchAgents() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');

    if (apiKey == null || apiKey.isEmpty) {
      print("❌ API key is missing in SharedPreferences.");
      return [];
    }

    try {
      final uri = Uri.parse(CommonApiClass.noOfAgents);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final nofAgents = NofAgents.fromJson(jsonResponse);
        final users = nofAgents.result?.users ?? [];

        // Save user count locally
        await prefs.setInt('userCount', users.length);

        print("✅ Fetched ${users.length} users.");
        for (var user in users) {
          print("🧑 ID: ${user.id}, Name: ${user.name}, Email: ${user.email}");
        }

        return users;
      } else {
        print("❌ Failed with status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error during API request: $e");
      return [];
    }
  }
}
