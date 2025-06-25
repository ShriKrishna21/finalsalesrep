import 'dart:convert';

import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/userlogoutmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class agentProfile extends StatefulWidget {
  const agentProfile({super.key});

  @override
  State<agentProfile> createState() => _agentProfileState();
}

class _agentProfileState extends State<agentProfile> {
  String? agentname;
  String? unitname;
  String? jobrole;
  String? userid;
  userlogout? logoutt;

  Future<void> agentLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('apikey');
    print(" nnnnnnnnnnnnnnnnnnnnnnnn${apiKey}");
    try {
      final url = CommonApiClass.agentProfile;
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

        print(" hashhhhhhhhhhhhhhhhhhhhhhhhhhhhhh${respond.statusCode}");
      }
      if (logoutt != null && logoutt!.result!.code == "200") {
        await prefs.clear();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Loginscreen(),
            ));

        print("Logout Success");
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
      backgroundColor: Colors.white, // Black background
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.black), // Black text
        ),
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
                  backgroundColor: Colors.black,
                  radius: 14,
                  child: Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // White background for the card
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
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
          Spacer(),
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
                        title: Text(
                          "Confirm Logout",
                          style: TextStyle(
                              color: Colors.black), // Black title text
                        ),
                        content: Text("Are you sure you want to logout?",
                            style: TextStyle(
                                color: Colors.black)), // Black content text
                        actions: [
                          TextButton(
                            child: Text("Cancel",
                                style: TextStyle(
                                    color: Colors.black)), // Black text
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors
                                      .red), // Red colored text for logout
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              agentLogout(); // Proceed with logout
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Red background for logout button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white), // White text for the button
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
              child: Text("$title",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black))), // Black text
          Text(":",
              style:
                  TextStyle(fontSize: 16, color: Colors.black)), // Black text
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black), // Black text
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
