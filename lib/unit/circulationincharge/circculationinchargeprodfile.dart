import 'dart:convert';

import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/userlogoutmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class circulationinchargeprofile extends StatefulWidget {
  const circulationinchargeprofile({super.key});

  @override
  State<circulationinchargeprofile> createState() =>
      _circulationinchargeprofileState();
}

class _circulationinchargeprofileState
    extends State<circulationinchargeprofile> {
  String? agentname;
  String? unitname;
  String? jobrole;
  String? userid;
  userlogout? logoutt;

  Future<void> agentLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('apikey');
    try {
      const url = 'http://10.100.13.138:8099/token_validation';
      final respond = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "params": {
            "token": apiKey.toString(),
          }
        }),
      );

      if (respond.statusCode == 200) {
        final jsonResponse = jsonDecode(respond.body) as Map<String, dynamic>;
        setState(() {
          logoutt = userlogout.fromJson(jsonResponse);
        });
      }
      if (logoutt != null && logoutt!.result!.code == "200") {
        await prefs.clear();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Loginscreen(),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Log out failed")),
        );
      }
    } catch (error) {
      print("something went wrong : $error");
    }
  }

  @override
  void initState() {
    super.initState();
    saveddata();
  }

  Future<void> saveddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      final String? name = prefs.getString('name');
      final int? id = prefs.getInt('id');
      final String? role = prefs.getString('role');
      final String? unit = prefs.getString('unit');
      agentname = name;
      userid = id.toString();
      jobrole = role;
      unitname = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black12,
                child: Icon(Icons.person, size: 60, color: Colors.black54),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 14,
                  child: Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileitem(title: "Name", value: agentname.toString()),
                profileitem(title: "User Name", value: userid.toString()),
                profileitem(title: "Job role", value: jobrole.toString()),
                profileitem(title: "Unit name", value: unitname.toString()),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text("Confirm Logout",
                            style: TextStyle(color: Colors.black)),
                        content: const Text("Are you sure you want to logout?",
                            style: TextStyle(color: Colors.black)),
                        actions: [
                          TextButton(
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Logout",
                                style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              agentLogout();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class profileitem extends StatelessWidget {
  const profileitem({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.black))),
          const Text(":", style: TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
