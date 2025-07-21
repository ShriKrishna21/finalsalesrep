import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Adharimage extends StatefulWidget {
  final int agentId;

  const Adharimage({super.key, required this.agentId});

  @override
  State<Adharimage> createState() => _AdharimageState();
}

class _AdharimageState extends State<Adharimage> {
  Uint8List? adharImageBytes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAdharImage();
  }

Future<void> fetchAdharImage() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('apikey');

  if (token == null) {
    setState(() {
      error = '🔑 Token not found.';
      isLoading = false;
    });
    return;
  }

  final url = Uri.parse('https://salesrep.esanchaya.com/api/user/id');

  try {
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "params": {
              "token": token,
              "id": widget.agentId,
            }
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🟢 Response Body: $data");

      final users = data['result']?['users'];
      if (users != null && users is List && users.isNotEmpty) {
        final user = users[0];
        final base64Image = user['aadhar_image'];

        if (base64Image != null && base64Image.isNotEmpty) {
          final cleanedBase64 = base64Image.contains(',')
              ? base64Image.split(',')[1]
              : base64Image;

          setState(() {
            adharImageBytes = base64Decode(cleanedBase64);
            isLoading = false;
          });
        } else {
          setState(() {
            error = '📭 Aadhaar image not found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = '👤 Agent data not found.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error = '❌ Server Error: ${response.statusCode}';
        isLoading = false;
      });
    }
  } on TimeoutException {
    setState(() {
      error = '⏰ Timeout: Server took too long to respond.';
      isLoading = false;
    });
  } on SocketException {
    setState(() {
      error = '📡 Network Error: Could not connect to server.';
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      error = '💥 Unexpected Error: $e';
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government ID Proof")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  )
                : adharImageBytes != null
                    ? Image.memory(adharImageBytes!)
                    : const Text("❌ No image available."),
      ),
    );
  }
}
