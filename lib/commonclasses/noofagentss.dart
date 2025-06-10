import 'dart:convert';
import 'package:finalsalesrep/modelclasses/noofagents.dart' show NofAgents, User;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class noofagents {
  Future<List<User>> fetchAgents() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    if (apiKey == null || userId == null) {
      print("❌ Missing API key or User ID");
      return [];
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.100.13.138:8099/api/users_you_created"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        final users = data.result?.users ?? [];

        await prefs.setInt('userCount', users.length); // Save count
        print("✅ Response received. Total users: ${users.length}");

        // Optional: print user details
        for (var user in users) {
          print("User ID: ${user.id}");
          print("User Name: ${user.name}");
          print("User Email: ${user.email}");
          print("-----");
        }

        return users;
      } else {
        print("❌ Server error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exception during API call: $e");
      return [];
    }
  }
}
