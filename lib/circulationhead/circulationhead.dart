import 'dart:convert';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/circulationhead/createregionalhead.dart';

class CirculationHead extends StatefulWidget {
  const CirculationHead({super.key});

  @override
  State<CirculationHead> createState() => _CirculationHeadState();
}

class _CirculationHeadState extends State<CirculationHead> {
  List<User> regionalHeads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRegionalHeads();
  }

  Future<void> fetchRegionalHeads() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    try {
      final response = await http.post(
        Uri.parse(CommonApiClass.noOfAgents),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final nofAgents = NofAgents.fromJson(jsonMap);

        setState(() {
          regionalHeads = nofAgents.result?.users
                  ?.where((user) => user.role == 'region_head')
                  .toList() ??
              [];
          isLoading = false;
        });
      } else {
        print("API Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const agentProfile()));
            },
            child: Icon(
              Icons.person,
              size: MediaQuery.of(context).size.height / 16,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          "Circulation Head",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : regionalHeads.isEmpty
              ? const Center(child: Text("No regional heads found"))
              : ListView.builder(
                  itemCount: regionalHeads.length,
                  itemBuilder: (context, index) {
                    final head = regionalHeads[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  head.name ?? "No Name",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text("User ID: ${head.email ?? "N/A"}"),
                              ]),
                          Text(
                            "Role: ${head.role ?? "Unknown"}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const createregionalhead()),
          );
          fetchRegionalHeads(); // Refresh after user creation
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Regional Head"),
      ),
    );
  }
}
