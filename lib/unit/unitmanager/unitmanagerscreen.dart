import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/unitmanager/profilescreen.dart';
import 'package:flutter/material.dart';

class Unitmanagerscreen extends StatefulWidget {
  const Unitmanagerscreen({super.key});

  @override
  State<Unitmanagerscreen> createState() => _UnitmanagerscreenState();
}

class _UnitmanagerscreenState extends State<Unitmanagerscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Profilescreen()));
            },
            child: Container(
              width: MediaQuery.of(context).size.height / 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white),
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
            text: "Unit Manager - ",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: <TextSpan>[
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Noofresources()));
                  },
                  child: _buildCard(
                    title: "Number of resources",
                    gradientColors: [
                      Colors.grey.shade200,
                      Colors.grey.shade400
                    ],
                    rows: [
                      _InfoRow(label: "Agents", value: ""),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: "Subscription Details",
                  gradientColors: [Colors.grey.shade200, Colors.grey.shade400],
                  rows: const [
                    _InfoRow(label: "Houses Count", value: "  ", bold: true),
                    _InfoRow(label: "Houses Visited", value: "0"),
                    _InfoRow(label: "Eenadu subscription", value: "0"),
                    _InfoRow(label: "Willing to change", value: "0"),
                    _InfoRow(label: "Not Interested", value: "0"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: "Route Map",
                  gradientColors: [Colors.grey.shade200, Colors.grey.shade400],
                  rows: const [
                    _InfoRow(label: "Routes", value: "0"),
                  ],
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.black,
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //       elevation: 4,
          //     ),
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => Createagent()));
          //     },
          //     child: const Text(
          //       "Create User",
          //       style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16,
          //           color: Colors.white),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Color> gradientColors,
    required List<_InfoRow> rows,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(2, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(children: rows),
          )
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 15, color: Colors.black)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
