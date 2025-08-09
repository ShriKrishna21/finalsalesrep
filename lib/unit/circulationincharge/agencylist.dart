import 'package:finalsalesrep/modelclasses/agencymodel.dart';
import 'package:finalsalesrep/unit/circulationincharge/agency_oneday_customerforms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: Agencylist(),
    debugShowCheckedModeBanner: false,
  ));
}

class Agencylist extends StatefulWidget {
  const Agencylist({super.key});

  @override
  State<Agencylist> createState() => _AgencylistState();
}

class _AgencylistState extends State<Agencylist> {
  List<AgencyData> agencies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgencies();
  }

  Future<void> fetchAgencies() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');

    final url =
        Uri.parse("https://salesrep.esanchaya.com/api/all_pin_locations");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final agencyModel = AgencyModel.fromJson(jsonData);

        setState(() {
          agencies = agencyModel.result?.data ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load agencies");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agencies')),
      body: isLoading
          // ? const Center(child: CircularProgressIndicator())
          // : agencies.isEmpty
          ? const Center(child: Text("No agencies found."))
          : ListView.builder(
              itemCount: agencies.length,
              itemBuilder: (context, index) {
                final agency = agencies[index];
                return ListTile(
                  // leading: CircleAvatar(
                  //   child: Text(
                  //     agency.name?.isNotEmpty == true
                  //         ? agency.name![0].toUpperCase()
                  //         : '?',
                  //   ),
                  // ),
                  //title: Text(agency.name ?? 'No Name'),
                  subtitle: GestureDetector(
                   onTap: () {
  final agencyName =
      '${agency.locationName ?? ''} [${agency.code ?? ''}]'; // match filter format
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AgencyOnedayCustomerforms(
        agencyName: agencyName,
      ),
    ),
  );
},
                    child: Text(
                      'Code: ${agency.code ?? 'N/A'}\nLocation: ${agency.locationName ?? 'N/A'}',
                    ),
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
