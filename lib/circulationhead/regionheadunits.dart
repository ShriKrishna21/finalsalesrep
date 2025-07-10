import 'dart:convert';
import 'package:finalsalesrep/regionalhead/UnitUsersScreen.dart';
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
  String token = '';

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchUnits();
  }

  Future<void> loadUserDataAndFetchUnits() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('apikey') ?? '';
    await fetchUnits();
  }

  Future<void> fetchUnits() async {
    final url =
        Uri.parse('https://salesrep.esanchaya.com/api/users_you_created/id');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = UserById.fromJson(data);
        final users = result.result?.users ?? [];

        final uniqueUnits = users
            .map((u) => u.unitName ?? '')
            .where((unit) => unit.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        setState(() {
          unitNames = uniqueUnits;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
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
          : unitNames.isEmpty
              ? const Center(child: Text("No Units Found"))
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                              builder: (context) =>
                                  UnitUsersScreen(unitName: unitNames[index]),
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
