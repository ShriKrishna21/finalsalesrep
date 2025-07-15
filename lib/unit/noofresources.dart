import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/agentdetailsscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Noofresources extends StatefulWidget {
  const Noofresources({super.key});

  @override
  State<Noofresources> createState() => _NoofresourcesState();
}

class _NoofresourcesState extends State<Noofresources> {
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';

  Future<void> agentdata() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (apiKey == null || unitName == null || unitName.isEmpty) {
      print("❌ Missing API key or unit name");
      setState(() => isLoading = false);
      return;
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
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = (data.result?.users ?? [])
            ..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          filteredUsers = users;
          isLoading = false;
        });

        await prefs.setInt('userCount', users.length);
      } else {
        print("❌ Error fetching agents. Status: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception during API call: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    agentdata();
  }

  void _filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users.where((user) {
        final nameMatch =
            user.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final idMatch = user.id?.toString().contains(query) ?? false;
        return nameMatch || idMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Localizations.numberOfResources),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                // 🔍 Search bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Id/AgentName",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _filterUsers,
                  ),
                ),

                // 📊 Total Agents Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${Localizations.totalagents} ${filteredUsers.length}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 📋 List of agents with swipe-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: agentdata,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AgentDetailsScreen(user: user),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          color: Colors.black54),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          user.name ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(color: Colors.grey),
                                  InfoRow(
                                      label: Localizations.emailOrUserId,
                                      value: user.id?.toString() ?? 'N/A'),
                                  InfoRow(
                                      label: Localizations.email,
                                      value: user.email ?? 'N/A'),
                                  InfoRow(
                                      label: Localizations.phone,
                                      value: user.phone ?? 'N/A'),
                                  InfoRow(
                                      label: Localizations.jobRole,
                                      value: user.role ?? 'N/A'),
                                  InfoRow(
                                      label: Localizations.unitName,
                                      value: user.unitName ?? 'N/A'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
