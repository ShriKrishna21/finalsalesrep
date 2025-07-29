import 'dart:convert';
import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/login/loginscreen.dart';
import 'package:finalsalesrep/modelclasses/userlogoutmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _agentProfileState();
}

class _agentProfileState extends State<Profilescreen> {
  String? agentname;
  String? unitname;
  String? jobrole;
  String? userid;
  userlogout? logoutt;

  Future<void> agentLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('apikey');

    try {
      final url = CommonApiClass.Profilescreen;
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
          MaterialPageRoute(builder: (context) => const Loginscreen()),
        );
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
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(Localizations.myProfile),
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
                child: Icon(Icons.person, size: 60, color: Colors.black),
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
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileitem(title: Localizations.name, value: agentname ?? ""),
                profileitem(title: Localizations.userName, value: userid ?? ""),
                profileitem(title: Localizations.jobRole, value: jobrole ?? ""),
                profileitem(
                    title: Localizations.unitName, value: unitname ?? ""),
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
                        title: Text(Localizations.confirmlogout),
                        actions: [
                          TextButton(
                            child: Text(Localizations.cancel,
                                style: const TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(Localizations.logout,
                                style: const TextStyle(color: Colors.red)),
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
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  Localizations.logout,
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
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
