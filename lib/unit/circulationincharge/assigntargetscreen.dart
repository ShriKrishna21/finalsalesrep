import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssignRouteScreen extends StatefulWidget {
  const AssignRouteScreen({super.key}); 

  @override
  State<AssignRouteScreen> createState() => _AssignRouteScreenState();
}

class _AssignRouteScreenState extends State<AssignRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _assignTargetController = TextEditingController();

  List<User> users = [];
  User? selectedAgent;
  bool isLoading = true;
  String? errorMessage;

  // From-To Controllers
  List<Map<String, TextEditingController>> fromToControllers = [
    {
      'from': TextEditingController(),
      'to': TextEditingController(),
    },
  ];

  @override
  void initState() {
    super.initState();
    agentdata();
  }

  @override
  void dispose() {
    _assignTargetController.dispose();
    for (var controller in fromToControllers) {
      controller['from']?.dispose();
      controller['to']?.dispose();
    }
    super.dispose();
  }

  Future<void> agentdata() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apikey');
    final unitName = prefs.getString('unit');

    if (apiKey == null || unitName == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Missing credentials";
      });
      return;
    }

    try {
      final requestBody = jsonEncode({
        "params": {
          "token": apiKey,
          "unit_name": unitName,
        }
      });
      debugPrint('Fetching agents: URL: ${CommonApiClass.agentUnitWise}');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(CommonApiClass.agentUnitWise),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('Agent fetch response: Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = NofAgents.fromJson(jsonResponse);

        setState(() {
          users = data.result?.users ?? [];
          selectedAgent = users.isNotEmpty ? users.first : null;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to fetch agents: ${response.statusCode}";
        });
      }
    } catch (e) {
      debugPrint('Agent fetch error: $e');
      setState(() {
        isLoading = false;
        errorMessage = "Network error";
      });
    }
  }

  Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null || token.isEmpty) {
      forceLogout("Session expired or invalid token");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/token_validation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      debugPrint('Token validation response: Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      final result = data['result'];

      if (result == null || result['success'] != true) {
        forceLogout(
            "Session expired. You may have logged in on another device.");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      forceLogout("Error validating session. Please log in again.");
      return false;
    }
  }

  void forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );
  }

  Future<bool> assignRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || selectedAgent == null || sessionId == null) {
      setState(() {
        errorMessage = "Missing credentials";
      });
      return false;
    }

    final fromToList = fromToControllers
        .where((pair) =>
            pair['from']!.text.trim().isNotEmpty &&
            pair['to']!.text.trim().isNotEmpty)
        .map((pair) => {
              "from_location": pair['from']!.text.trim(),
              "to_location": pair['to']!.text.trim(),
            })
        .toList();

    if (fromToList.isEmpty) {
      setState(() {
        errorMessage = "At least one route is required";
      });
      return false;
    }

    // Validate for duplicate routes
    final routeSet = <String>{};
    for (var route in fromToList) {
      final routeKey = "${route['from_location']}-${route['to_location']}";
      if (routeSet.contains(routeKey)) {
        setState(() {
          errorMessage = "Duplicate route detected";
        });
        return false;
      }
      routeSet.add(routeKey);
    }

    final requestBody = jsonEncode({
      "params": {
        "token": token,
        "agent_id": selectedAgent!.id.toString(),
        "from_to_list": fromToList,
      }
    });

    try {
      final url = 'https://salesrep.esanchaya.com/api/For_root_map_asin';
      debugPrint('Assign Route: URL: $url');
      debugPrint(
          'Headers: {Content-Type: application/json, Cookie: session_id=$sessionId}');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: requestBody,
      );

      debugPrint('Assign Route response: Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final success =
            jsonResponse["result"]?["success"]?.toString() == "True";
        if (!success) {
          setState(() {
            errorMessage =
                jsonResponse["result"]?["message"] ?? "Failed to assign route";
          });
        }
        return success;
      } else {
        setState(() {
          errorMessage = "Failed to assign route: ${response.statusCode}";
        });
        return false;
      }
    } catch (e) {
      debugPrint('Assign Route error: $e');
      setState(() {
        errorMessage = "Network error";
      });
      return false;
    }
  }

  Future<bool> assignTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || sessionId == null || selectedAgent == null) {
      setState(() {
        errorMessage = "Missing credentials";
      });
      return false;
    }

    final target = int.tryParse(_assignTargetController.text.trim());
    if (target == null || target <= 0) {
      setState(() {
        errorMessage = "Invalid target value";
      });
      return false;
    }

    final requestBody = jsonEncode({
      "params": {
        "user_id": selectedAgent!.id.toString(),
        "token": token,
        "target": target,
      }
    });

    try {
      final url = 'https://salesrep.esanchaya.com/update/target';
      debugPrint('Assign Target: URL: $url');
      debugPrint(
          'Headers: {Content-Type: application/json, Cookie: session_id=$sessionId}');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: requestBody,
      );

      debugPrint('Assign Target response: Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final success =
            jsonResponse["result"]?["success"]?.toString() == "True";
        if (!success) {
          setState(() {
            errorMessage =
                jsonResponse["result"]?["message"] ?? "Failed to assign target";
          });
        }
        return success;
      } else {
        setState(() {
          errorMessage = "Failed to assign target: ${response.statusCode}";
        });
        return false;
      }
    } catch (e) {
      debugPrint('Assign Target error: $e');
      setState(() {
        errorMessage = "Network error";
      });
      return false;
    }
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate() && selectedAgent != null) {
      setState(() {
        errorMessage = null;
        isLoading = true;
      });

      // Validate token before submitting
      final isTokenValid = await validateToken();
      if (!isTokenValid) {
        setState(() => isLoading = false);
        return;
      }

      final routeSuccess = await assignRoute();
      final targetSuccess = await assignTarget();

      setState(() => isLoading = false);

      if (routeSuccess && targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Route and target assigned successfully"),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? "Both assignments failed"),
          ),
        );
      }
    } else {
      setState(() {
        errorMessage = "Please select an agent and fill all fields";
      });
    }
  }

  void _addFromToField() {
    setState(() {
      fromToControllers.add({
        'from': TextEditingController(),
        'to': TextEditingController(),
      });
    });
  }

  void _removeFromToField(int index) {
    if (fromToControllers.length > 1) {
      setState(() {
        fromToControllers[index]['from']?.dispose();
        fromToControllers[index]['to']?.dispose();
        fromToControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Route and Target")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: agentdata,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      DropdownButtonFormField<User>(
                        decoration: const InputDecoration(
                          labelText: "Select Agent",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedAgent,
                        items: users.map((User user) {
                          return DropdownMenuItem<User>(
                            value: user,
                            child: Text('${user.name} (ID: ${user.id})'),
                          );
                        }).toList(),
                        onChanged: (User? newValue) {
                          setState(() {
                            selectedAgent = newValue;
                            errorMessage = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Please select an agent" : null,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fromToControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: fromToControllers[index]
                                        ['from'],
                                    decoration: const InputDecoration(
                                      labelText: "From",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? "Please enter From location"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: fromToControllers[index]['to'],
                                    decoration: const InputDecoration(
                                      labelText: "To",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? "Please enter To location"
                                            : null,
                                  ),
                                ),
                                if (fromToControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () => _removeFromToField(index),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addFromToField,
                          icon: const Icon(Icons.add),
                          label: const Text("Add From-To"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _assignTargetController,
                        decoration: const InputDecoration(
                          labelText: "Assign Target",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a target";
                          }
                          final target = int.tryParse(value.trim());
                          if (target == null || target <= 0) {
                            return "Please enter a valid positive number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
