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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: "$staffName\n"),
              TextSpan(
                text: unitName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Office Staff Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.grey[100],
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.black),
                title: const Text("View created agents",
                    style: TextStyle(color: Colors.black)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Viewcreatedagents()),
                  );
                },
              ),
            ),
            // Card(
            //   color: Colors.grey[100],
            //   elevation: 2,
            //   child: ListTile(
            //     leading: const Icon(Icons.settings, color: Colors.black),
            //     title: const Text("Manage Unit Info",
            //         style: TextStyle(color: Colors.black)),
            //     trailing: const Icon(Icons.arrow_forward_ios,
            //         size: 16, color: Colors.grey),
            //     onTap: () {
            //       // Navigate to manage unit
            //     },
            //   ),
            // ),
            const SizedBox(height: 24),
            Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAgent()));
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add),
                label: const Text('Create Agent'),
              ),
            ),
            const Spacer(),
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       // Implement logout
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red,
            //       foregroundColor: Colors.white,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     ),
            //     icon: const Icon(Icons.logout),
            //     label: const Text("Logout"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
