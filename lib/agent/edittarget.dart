import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class edittarget extends StatefulWidget {
  final int userId;
  final String token;

  const edittarget({super.key, required this.userId, required this.token});

  @override
  State<edittarget> createState() => _edittargetState();
}

class _edittargetState extends State<edittarget> {
  final TextEditingController _targetController = TextEditingController();
  bool _isSubmitting = false;

  Future<bool> assignTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');

    if (sessionId == null || widget.token.isEmpty) return false;

    final params = {
      "params": {
        "user_id": widget.userId,
        "token": widget.token,
        "target": int.tryParse(_targetController.text.trim()) ?? 0,
      }
    };

    print("Sending Target Update Params: ${jsonEncode(params)}");

    final response = await http.post(
      Uri.parse("https://salesrep.esanchaya.com/update/target"),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode(params),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final result = jsonDecode(response.body);
    return result["result"]?["success"] == "True";
  }

  void _submitTarget() async {
    if (_targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a target")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await assignTarget();
    setState(() => _isSubmitting = false);

    if (success) {
      // Save the updated target to SharedPreferences for consistency
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('target', _targetController.text.trim());

      // Return success to the previous screen
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update target")),
      );
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Target")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter New Target",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitTarget,
                    child: const Text("Update Target"),
                  ),
          ],
        ),
      ),
    );
  }
}