import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/regionalhead/unitscreen.dart';
import 'package:flutter/material.dart';

class Reginoalheadscreen extends StatefulWidget {
  const Reginoalheadscreen({super.key});

  @override
  State<Reginoalheadscreen> createState() => _ReginoalheadscreenState();
}

class _ReginoalheadscreenState extends State<Reginoalheadscreen> {
  final List<Map<String, String>> units = [
    {'name': 'Unit 1', 'location': 'Karimnagar'},
    {'name': 'Unit 2', 'location': 'Warangal'},
    {'name': 'Unit 3', 'location': 'Hyderabad'},
    {'name': 'Unit 4', 'location': 'Nizamabad'},
    {'name': 'Unit 5', 'location': 'Adilabad'},
  ];

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => agentProfile(),));
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
                text: "Puma\n",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "karimnagar",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.location_city, color: Colors.blue),
              title: Text(unit['name'] ?? ''),
              subtitle: Text(unit['location'] ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Unitscreen(),));
                // Navigate to unit-specific screen
              },
            ),
          );
        },
      ),
    );
  }
}
