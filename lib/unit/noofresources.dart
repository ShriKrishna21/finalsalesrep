import 'dart:convert';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/AgentDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Noofresources extends StatefulWidget {
  const Noofresources({super.key});

  @override
  State<Noofresources> createState() => _NoofresourcesState();
}

class _NoofresourcesState extends State<Noofresources> {
  List<User> users = [];
  bool isLoading = true;

  // Function to fetch user data
  Future<void> agentdata() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final userId = prefs.getInt('id');
    
    if (apiKey == null || userId == null) {
      print("❌ Missing API key or User ID");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.100.13.138:8099/api/users_you_created"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {
            "token": apiKey,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = data.result?.users ?? [];
          isLoading = false;
        });

        await prefs.setInt('userCount', users.length);  // Save the count to SharedPreferences
        print("✅ Response: $jsonResponse");

        // Print user details to console
        users.forEach((user) {
          print("count: ${users.length}");
          print("User ID: ${user.id}");
          print("User Name: ${user.name}");
          print("User Email: ${user.email}");
          print("-----");
        });
      } else {
        print("❌ Fetch error. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API not implemented: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    agentdata();  // Fetch agent data on initial load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Number of Resources")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No users found"))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(user.name ?? 'N/A'),
                        subtitle: Text(user.id.toString() ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                               AgentDetailsScreen   (user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
