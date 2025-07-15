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
  List<User> filteredAgents = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCreatedAgents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

        if (data.result?.users != null && data.result!.users!.isNotEmpty) {
          List<User> sortedAgents = data.result!.users!;
          sortedAgents.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

          setState(() {
            agents = sortedAgents;
            filteredAgents = sortedAgents;
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

  void _filterAgents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAgents = List.from(agents);
      } else {
        final lowerQuery = query.toLowerCase();
        filteredAgents = agents.where((user) {
          final nameMatch =
              user.name?.toLowerCase().contains(lowerQuery) ?? false;
          final idMatch = user.id?.toString().contains(lowerQuery) ?? false;
          return nameMatch || idMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Created Agents")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agents.isEmpty
              ? const Center(child: Text("No agents created"))
              : Column(
                  children: [
                    // 🔍 Search bar
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterAgents,
                        decoration: InputDecoration(
                          hintText: "Search by Agent Name or ID",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // 📋 Agent list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredAgents.length,
                        itemBuilder: (context, index) {
                          final agent = filteredAgents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                agent.name ?? "No Name",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Email: ${agent.email ?? 'N/A'}"),
                                  Text("Phone: ${agent.phone ?? 'N/A'}"),
                                  Text("Unit: ${agent.unitName ?? 'N/A'}"),
                                  Text("Status: ${agent.status ?? 'N/A'}"),
                                  Text("ID: ${agent.id ?? 'N/A'}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
