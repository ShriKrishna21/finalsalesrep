import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GovtIdImages extends StatefulWidget {
  final int agentId;
  const GovtIdImages({Key? key, required this.agentId}) : super(key: key);

  @override
  _GovtIdImagesState createState() => _GovtIdImagesState();
}

class _GovtIdImagesState extends State<GovtIdImages> {
  Uint8List? aadhaarBytes;
  Uint8List? panBytes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchIdProofImages();
  }

  Future<void> _fetchIdProofImages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    if (token == null) {
      setState(() {
        error = '🔑 API token not found';
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
              "params": {"token": token, "id": widget.agentId},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw HttpException('Server error ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final users = data['result']?['users'] as List<dynamic>?;

      if (users == null || users.isEmpty) {
        throw Exception('Agent not found');
      }

      Uint8List? decodeImage(String? b64) {
        if (b64 == null || b64.isEmpty) return null;
        final clean = b64.contains(',') ? b64.split(',')[1] : b64;
        try {
          return base64Decode(clean);
        } catch (_) {
          return null;
        }
      }

      final user = users.first as Map<String, dynamic>;
      setState(() {
        aadhaarBytes = decodeImage(user['aadhar_image'] as String?);
        panBytes = decodeImage(user['pan_image'] as String?);
        isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        error = '⏰ Request timed out';
        isLoading = false;
      });
    } on SocketException {
      setState(() {
        error = '📡 Network error';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '💥 Error: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildImageTile(String title, Uint8List? bytes) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: bytes != null
                ? GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: InteractiveViewer(
                          child: Image.memory(bytes),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(bytes, fit: BoxFit.cover),
                    ),
                  )
                : Center(child: Text('❌ No $title')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government ID Proofs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : (aadhaarBytes != null || panBytes != null)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              _buildImageTile('Aadhaar Card', aadhaarBytes),
                              const SizedBox(width: 16),
                              _buildImageTile('PAN Card', panBytes),
                            ],
                          ),
                        ],
                      )
                    : const Center(child: Text('❌ No ID images found')),
      ),
    );
  }
}
