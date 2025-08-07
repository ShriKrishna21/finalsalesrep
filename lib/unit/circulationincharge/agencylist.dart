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
    final token = prefs.getString('apikey') ??
        'f3657113a9e3588cd9908364cb5117400370b2bea0640e887f74540b1c0b2aaf'; // Fallback token

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
                  subtitle: Text(
                    'Code: ${agency.code ?? 'N/A'}\nLocation: ${agency.locationName ?? 'N/A'}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}

//
// ---------------------- MODEL CLASSES ----------------------
//

class AgencyModel {
  String? jsonrpc;
  dynamic id;
  AgencyResult? result;

  AgencyModel({this.jsonrpc, this.id, this.result});

  AgencyModel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? AgencyResult.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class AgencyResult {
  bool? success;
  List<AgencyData>? data;

  AgencyResult({this.success, this.data});

  AgencyResult.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AgencyData>[];
      json['data'].forEach((v) {
        data!.add(AgencyData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AgencyData {
  int? id;
  String? name;
  String? code;
  String? locationName;

  AgencyData({this.id, this.name, this.code, this.locationName});

  AgencyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    code = json['code']?.toString();
    locationName = json['location_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['location_name'] = locationName;
    return data;
  }
}
