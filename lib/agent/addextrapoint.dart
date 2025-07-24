import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Addextrapoint extends StatefulWidget {
  final int routeId;
  final List<Map<String, dynamic>> fromToIds;

  const Addextrapoint({
    Key? key,
    required this.routeId,
    required this.fromToIds,
  }) : super(key: key);

  @override
  State<Addextrapoint> createState() => _AddextrapointState();
}

class _AddextrapointState extends State<Addextrapoint> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.fromToIds
        .map((entry) =>
            TextEditingController(text: entry['extra_point']?.toString() ?? ''))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> saveExtraPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token not found. Please login again.")),
      );
      return;
    }

    bool allSuccessful = true;

    for (int i = 0; i < widget.fromToIds.length; i++) {
      final fromToId = widget.fromToIds[i]['id'];
      final extraPoint = controllers[i].text;

      final url =
          Uri.parse('https://salesrep.esanchaya.com/api/for_assign_extra_point');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "extra_point": extraPoint,
            "location_id": fromToId,
            "token": token,
          }
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result']?['success'] != true) {
          allSuccessful = false;
          debugPrint("Failed for ID $fromToId: ${response.body}");
        }
      } else {
        allSuccessful = false;
        debugPrint("HTTP error for ID $fromToId: ${response.statusCode}");
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allSuccessful
            ? "Extra point(s) added successfully"
            : "Some extra points failed to save"),
      ),
    );

    if (allSuccessful) {
      Navigator.pop(context, true); // return true so previous screen can refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Route - ID: ${widget.routeId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveExtraPoints,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.fromToIds.length,
        itemBuilder: (context, index) {
          final entry = widget.fromToIds[index];
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID: ${entry['id'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "From: ${entry['from_location'] ?? 'N/A'}\nTo: ${entry['to_location'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controllers[index],
                      decoration: const InputDecoration(
                        labelText: "Extra Point",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
