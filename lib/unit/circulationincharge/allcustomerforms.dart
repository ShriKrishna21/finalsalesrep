import 'package:finalsalesrep/agent/onedayhistory.dart';
import 'package:finalsalesrep/modelclasses/customerformsunitwise.dart';
import 'package:finalsalesrep/unit/circulationincharge/agency_total_customerforms.dart';
import 'package:finalsalesrep/unit/circulationincharge/todayagencylist.dart';
import 'package:finalsalesrep/unit/circulationincharge/totalagencylist.dart';
import 'package:flutter/material.dart';


class Allcustomerforms extends StatefulWidget {
  const Allcustomerforms({super.key});

  @override
  State<Allcustomerforms> createState() =>
      _AllcustomerformsState();
}

class _AllcustomerformsState extends State<Allcustomerforms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today Overall History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Today History Field
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text(
                  'Today History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => todayagencylist(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Overall History Field
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text(
                  'Overall History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>totalagencylist(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
