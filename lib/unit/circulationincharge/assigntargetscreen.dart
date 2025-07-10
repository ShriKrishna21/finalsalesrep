import 'dart:convert';
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

  final TextEditingController _agentIdController = TextEditingController();
  final TextEditingController _routeMapController = TextEditingController();
  final TextEditingController _assignTargetController = TextEditingController();

  Future<bool> assignRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found')),
      );
      return false;
    }

    final response = await http.post(
      Uri.parse('https://salesrep.esanchaya.com/api/For_root_map_asin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "params": {
          "token": token,
          "agent_id": _agentIdController.text.trim(),
          "root_map": _routeMapController.text.trim(),
        }
      }),
    );

    if (response.statusCode == 200) {
      print("Route Assigned ✅: ${response.statusCode}");
      return true;
    } else {
      print("Route Failed ❌: ${response.statusCode}");
      return false;
    }
  }

  Future<bool> assignTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final sessionId = prefs.getString('session_id');

    if (token == null || sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing token or session ID')),
      );
      return false;
    }

    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/update/target"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId', // 🔑 Important for session
      },
      body: jsonEncode({
        "params": {
          "user_id": _agentIdController.text.trim(),
          "token": token,
          "target":
              int.parse(_assignTargetController.text.trim()), // Ensure int type
        }
      }),
    );

    print("Target Status: ${response.statusCode}");
    print("Target Response: ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result["result"]?["success"] == "True") {
        return true;
      }
    }

    return false;
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final bool routeSuccess = await assignRoute();
      final bool targetSuccess = await assignTarget();

      if (routeSuccess && targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Route and Target assigned successfully')),
        );
        Navigator.of(context).pop();
      } else if (!routeSuccess && !targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Both assignments failed')),
        );
      } else if (!routeSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route assignment failed')),
        );
      } else if (!targetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target assignment failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Route & Target')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _agentIdController,
                decoration: const InputDecoration(
                  labelText: 'Agent ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Agent ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeMapController,
                decoration: const InputDecoration(
                  labelText: 'Route Map',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Route Map' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assignTargetController,
                decoration: const InputDecoration(
                  labelText: 'Assign Target',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Target' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
