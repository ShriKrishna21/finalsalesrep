import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/officestaff.dart/viewcreatedagents.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfficeStaffScreen extends StatefulWidget {
  const OfficeStaffScreen({super.key});

  @override
  State<OfficeStaffScreen> createState() => _OfficeStaffScreenState();
}

class _OfficeStaffScreenState extends State<OfficeStaffScreen> {
  String staffName = '';
  String unitName = '';

  @override
  void initState() {
    super.initState();
    loadStaffInfo();
  }

  Future<void> loadStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      staffName = prefs.getString('name') ?? 'Office Staff';
      unitName = prefs.getString('unit') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const agentProfile()),
              );
            },
          )
        ],
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: "$staffName\n"),
              TextSpan(
                text: unitName,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateAgent()));
              },
              label: const Text('Create Agent'),
              icon: const Icon(Icons.person_add),
             
            ),
            Text(
              "Office Staff Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text("View created agents"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Viewcreatedagents(),));
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Manage Unit Info"),
                onTap: () {
                  // Navigate to manage unit
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement logout
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
