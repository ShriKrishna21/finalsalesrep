import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Addextrapoint extends StatefulWidget {
  final int routeId;
  final List<Map<String, dynamic>> fromToIds;

  const Addextrapoint({
    super.key,
    required this.routeId,
    required this.fromToIds,
  });

  @override
  State<Addextrapoint> createState() => _AddextrapointState();
}

class _AddextrapointState extends State<Addextrapoint> {
  late List<List<TextEditingController>> controllersList;

  @override
  void initState() {
    super.initState();
    // Initialize controllersList with one controller per extra point for each fromTo entry
    controllersList = widget.fromToIds.map((entry) {
      final extraPoints = entry['extra_points'] as List<dynamic>? ?? [];
      return extraPoints.isNotEmpty
          ? extraPoints
              .map((ep) => TextEditingController(text: ep['name']?.toString() ?? ''))
              .toList()
          : [TextEditingController()];
    }).toList();
  }

  @override
  void dispose() {
    for (final controllers in controllersList) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void addExtraPointField(int fromToIndex) {
    setState(() {
      controllersList[fromToIndex].add(TextEditingController());
    });
  }

  void removeExtraPointField(int fromToIndex, int controllerIndex) {
    setState(() {
      if (controllersList[fromToIndex].length > 1) {
        controllersList[fromToIndex][controllerIndex].dispose();
        controllersList[fromToIndex].removeAt(controllerIndex);
      }
    });
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
      final extraPointNames = controllersList[i]
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final url =
          Uri.parse('https://salesrep.esanchaya.com/api/for_assign_extra_point');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "location_id": fromToId,
            "extra_point_names": extraPointNames,
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
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Route - ID: ${widget.routeId}'),
        actions: const [
        
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
                    ...controllersList[index].asMap().entries.map((entry) {
                      final controllerIndex = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: "Extra Point",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (controllersList[index].length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => removeExtraPointField(index, controllerIndex),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () => addExtraPointField(index),
                      ),
                    ),
                    Center(child: ElevatedButton(onPressed:  saveExtraPoints, child: const Text("Update route")))
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