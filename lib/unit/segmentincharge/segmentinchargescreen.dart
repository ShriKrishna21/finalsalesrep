import 'package:finalsalesrep/unit/segmentincharge/approvedagents.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/unit/officestaff.dart/createagent.dart';
import 'package:finalsalesrep/unit/noofresources.dart';
import 'package:finalsalesrep/unit/segmentincharge/approveagents.dart';

class Segmentinchargescreen extends StatefulWidget {
  const Segmentinchargescreen({super.key});

  @override
  State<Segmentinchargescreen> createState() => _SegmentinchargescreenState();
}

class _SegmentinchargescreenState extends State<Segmentinchargescreen> {
  String userName = '';
  String unitt = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Unknown';
      unitt = prefs.getString('unit') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const agentProfile()),
              );
            },
          )
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Segment Incharge", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(userName, style: const TextStyle(fontSize: 14)),
            Text(unitt, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Noofresources()));
              },
              child: _buildCard(
                title: "Number of Resources",
                rows: const [
                  _InfoRow(label: "Agents", value: ""),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Subscription Details",
              rows: const [
                _InfoRow(label: "Houses Count", value: "", bold: true),
                _InfoRow(label: "Houses Visited", value: "0"),
                _InfoRow(label: "Eenadu subscription", value: "0"),
                _InfoRow(label: "Willing to change", value: "0"),
                _InfoRow(label: "Not Interested", value: "0"),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Route Map",
              rows: const [
                _InfoRow(label: "Routes", value: "0"),
              ],
            ),
            Spacer(),
              SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const approvedagents()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                ),
                
                child: const Text("Approved Agents", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Approveagents()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text("In-progress Agents", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
          const SizedBox(height: 8),
          Column(children: rows),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const Text(": "),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
