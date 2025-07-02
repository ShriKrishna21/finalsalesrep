import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Viewcreatedagents extends StatefulWidget {
  const Viewcreatedagents({super.key});

  @override
  State<Viewcreatedagents> createState() => _ViewcreatedagentsState();
}

class _ViewcreatedagentsState extends State<Viewcreatedagents> {
  List<User> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCreatedAgents();
  }

  Future<void> fetchCreatedAgents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('apikey');

    try {
      final response = await http.post(
        Uri.parse(CommonApiClass.noOfAgents),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        if (data.result?.users != null) {
          setState(() {
            agents = data.result!.users!;
            isLoading = false;
          });
        } else {
          throw Exception("No users found");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Created Agents")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agents.isEmpty
              ? const Center(child: Text("No agents created"))
              : ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(agent.name ?? "No Name",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${agent.email ?? 'N/A'}"),
                            Text("Phone: ${agent.phone ?? 'N/A'}"),
                            Text("Unit: ${agent.unitName ?? 'N/A'}"),
                            Text("Status: ${agent.status ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
