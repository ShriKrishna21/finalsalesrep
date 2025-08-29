import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/selfietimeresponse.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class unittodaystaffattendance extends StatefulWidget {
  final int userid;

  const unittodaystaffattendance({super.key, required this.userid});

  @override
  State<unittodaystaffattendance> createState() => _unittodaystaffattendanceState();
}

class _unittodaystaffattendanceState extends State<unittodaystaffattendance> {
  List<SelfieSession> _selfieSessions = [];

  @override
  void initState() {
    super.initState();
    fetchSelfieTimes();
  }

  Future<void> fetchSelfieTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final userId = prefs.getInt('id');

    debugPrint("🔍 Token: $token, UserId: $userId");

    if (token == null || userId == null) {
      debugPrint("❌ Missing token or userId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing token or user ID")),
      );
      return;
    }

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await http.post(
        Uri.parse("https://salesrep.esanchaya.com/api/user/today_selfies"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {
            "token": token,
            "user_id": widget.userid,
            "date": today,
          }
        }),
      );

      debugPrint("🔁 Selfie Times Status Code: ${response.statusCode}");
      debugPrint("🔁 Selfie Times Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("🔍 Parsed JSON: $data");

        if (data == null || data['result'] == null) {
          debugPrint("❌ Invalid response structure: Missing 'result' key");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid response from server")),
          );
          return;
        }

        final selfieData = SelfieTimesResponse.fromJson(data);

        debugPrint("🔍 SelfieTimesResponse: success=${selfieData.success}, "
            "sessions=${selfieData.sessions.map((s) => {
                  'startTime': s.startTime,
                  'endTime': s.endTime,
                  'startSelfie': s.startSelfie != null
                      ? '${s.startSelfie!.substring(0, s.startSelfie!.length > 50 ? 50 : s.startSelfie!.length)}...'
                      : null,
                  'endSelfie': s.endSelfie != null
                      ? '${s.endSelfie!.substring(0, s.endSelfie!.length > 50 ? 50 : s.endSelfie!.length)}...'
                      : null,
                }).toList()}");

        if (selfieData.success) {
          try {
            setState(() {
              _selfieSessions = selfieData.sessions;
            });
          } catch (e) {
            debugPrint("❌ Error in setState: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating UI: $e")),
            );
          }
        } else {
          debugPrint("❌ Selfie times fetch unsuccessful: ${selfieData.success}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch selfie times")),
          );
        }
      } else {
        debugPrint("❌ Failed to fetch selfie times: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to fetch selfie times: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error fetching selfie times: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching selfie times: $e")),
      );
    }
  }

  void _showSelfieDialog(String? base64Image, String title) {
    if (base64Image == null || base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No selfie available")),
      );
      return;
    }

    final cleanBase64 = base64Image.startsWith('data:image')
        ? base64Image.split(',')[1]
        : base64Image;

    try {
      base64Decode(cleanBase64);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  base64Decode(cleanBase64),
                  width: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "Error loading image",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("❌ Error decoding base64 image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid image data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Filter sessions to include only those from today
    final todaySessions = _selfieSessions.where((session) {
      if (session.startTime == null) return false;
      final sessionDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(session.startTime!));
      return sessionDate == today;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Attendance - ${widget.userid ?? 'Unknown'}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Today's attendance details for ${widget.userid ?? 'Unknown'} - ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSectionTitle(localizations.shiftdetails),
            ),
            const SizedBox(height: 10),
            if (todaySessions.isNotEmpty)
              ...todaySessions.asMap().entries.map((sessionEntry) {
                final index = sessionEntry.key;
                final session = sessionEntry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${localizations.session} ${index + 1}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (session.startTime != null)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showSelfieDialog(
                                  session.startSelfie,
                                  localizations.startselfie,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        localizations.starttime,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        session.startTime != null
                                            ? DateFormat('hh:mm a').format(
                                                DateTime.parse(session.startTime!))
                                            : "--",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (session.startTime != null && session.endTime != null)
                            const SizedBox(width: 12),
                          if (session.endTime != null)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showSelfieDialog(
                                  session.endSelfie,
                                  localizations.endselfie,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        localizations.endtime,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        session.endTime != null
                                            ? DateFormat('hh:mm a').format(
                                                DateTime.parse(session.endTime!))
                                            : "--",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (session.startTime != null && session.endTime != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                localizations.totalworkinghours,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                () {
                                  final start = DateTime.tryParse(session.startTime!);
                                  final end = DateTime.tryParse(session.endTime!);
                                  if (start != null && end != null) {
                                    final duration = end.difference(start);
                                    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
                                  }
                                  return "--";
                                }(),
                              ),
                            ],
                          ),
                        )
                      else if (session.startTime != null && session.endTime == null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                localizations.sessionongoing,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                localizations.workinprogressendtimenotset,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    localizations.noshiftdataavailable,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      );
}