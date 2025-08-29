import 'dart:convert';
import 'package:finalsalesrep/regionalhead/unitwisescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:finalsalesrep/modelclasses/usersbyid.dart';

class Regionheadunits extends StatefulWidget {
  final int userId;

  const Regionheadunits({super.key, required this.userId});

  @override
  State<Regionheadunits> createState() => _RegionheadunitsState();
}

class _RegionheadunitsState extends State<Regionheadunits> {
  List<String> unitNames = [];
  bool isLoading = true;
  String? errorMessage;
  String token = '';

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchUnits();
  }

  Future<void> loadUserDataAndFetchUnits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('apikey') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No API token found. Please log in again.';
        });
        return;
      }
      await fetchUnits();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data: $e';
      });
    }
  }
Future<void> fetchUnits() async {
  final url = Uri.parse('https://salesrep.esanchaya.com/api/users_you_created/id');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "params": {
          "token": token,
          "id": widget.userId,
        }
      }),
    );

    debugPrint('Request URL: $url');
    debugPrint('Request Body: ${jsonEncode({"params": {"token": token, "id": widget.userId}})}');
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null || data.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No data returned from the server.';
        });
        return;
      }

      final result = UserById.fromJson(data);
      final users = result.result?.users ?? [];

      if (users.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No users found for this ID.';
        });
        return;
      }

      final uniqueUnits = users
          .map((u) => u.unitName ?? '')
          .where((unit) => unit.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        unitNames = uniqueUnits;
        isLoading = false;
        errorMessage = null;
        debugPrint('Unit Names: $unitNames'); // Debug unit names
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Server error: ${response.statusCode} - ${response.reasonPhrase}';
      });
    }
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Failed to fetch units: $e';
    });
    debugPrint('Error: $e'); // Debug error
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Units Created"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : unitNames.isEmpty
                  ? const Center(child: Text("No Units Found", style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      itemCount: unitNames.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black, width: 1.2),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              unitNames[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnitUsersScreen(unitName: unitNames[index]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}