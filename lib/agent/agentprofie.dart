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
    print("API Key: $apiKey");

    try {
      final url = CommonApiClass.agentProfile;
      final respond = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": apiKey.toString()}
        }),
      );

      if (respond.statusCode == 200) {
        final jsonResponse = jsonDecode(respond.body) as Map<String, dynamic>;
        logoutt = userlogout.fromJson(jsonResponse);
      }

      if (logoutt != null && logoutt!.result!.code == "200") {
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Loginscreen()),
          (Route<dynamic> route) => false,
        );
        print("Logout Success");
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Log out failed")),
        );
      }
    } catch (error) {
      print("Error: $error");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during logout")),
      );
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
      agentname = prefs.getString('name');
      userid = prefs.getInt('id')?.toString();
      jobrole = prefs.getString('role');
      unitname = prefs.getString('unit');
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final Localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          Localizations.myProfile,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: saveddata,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 20),
            const Stack(
              alignment: Alignment.bottomRight,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 60, color: Colors.black54),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 150,
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
                boxShadow: const [
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
                  profileitem(
                      title: Localizations.name, value: agentname ?? "-"),
                  profileitem(
                      title: Localizations.userid, value: userid ?? "-"),
                  profileitem(
                      title: Localizations.jobRole, value: jobrole ?? "-"),
                  profileitem(
                      title: Localizations.unitName, value: unitname ?? "-"),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
                          title: Text(Localizations.confirmlogout,
                              style: const TextStyle(color: Colors.black)),
                          content: Text(Localizations.areyousureyouwanttologout,
                              style: const TextStyle(color: Colors.black)),
                          actions: [
                            TextButton(
                              child: Text(Localizations.cancel,
                                  style: const TextStyle(color: Colors.black)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text(Localizations.logout,
                                  style: const TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                agentLogout(); // Proceed with logout
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
                  child: Text(Localizations.logout,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
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
