import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/regionalhead/createunits.dart';

import 'package:finalsalesrep/regionalhead/unitscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reginoalheadscreen extends StatefulWidget {
  const Reginoalheadscreen({super.key});

  @override
  State<Reginoalheadscreen> createState() => _ReginoalheadscreenState();
}

class _ReginoalheadscreenState extends State<Reginoalheadscreen> {
  String? username;
  String? unit;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? 'Unknown';
      unit = prefs.getString('unit') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height / 12,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => agentProfile(),
                    ));
              },
              child: Container(
                width: MediaQuery.of(context).size.height / 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: MediaQuery.of(context).size.height / 16,
                ),
              ),
            )
          ],
          title: RichText(
            text: TextSpan(
              text: "RegionalHead  - ",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "${username ?? ''}\n",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: unit ?? '',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Createincharge()),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Create incharge"),
            )
          ],
        ));
  }
}
