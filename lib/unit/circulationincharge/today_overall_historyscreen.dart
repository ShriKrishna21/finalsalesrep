import 'package:finalsalesrep/agent/onedayhistory.dart';
import 'package:finalsalesrep/modelclasses/customerformsunitwise.dart';
import 'package:finalsalesrep/unit/circulationincharge/agencylist.dart';
import 'package:finalsalesrep/unit/unitmanager/allcustomerforms.dart';
import 'package:flutter/material.dart';

// Dummy screens (replace these with your actual screen widgets)
class TodayHistoryScreen extends StatelessWidget {
  const TodayHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today History')),
      body: const Center(child: Text('Today History Details')),
    );
  }
}

class OverallHistoryScreen extends StatelessWidget {
  const OverallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overall History')),
      body: const Center(child: Text('Overall History Details')),
    );
  }
}

class TodayOverallHistoryscreen extends StatefulWidget {
  const TodayOverallHistoryscreen({super.key});

  @override
  State<TodayOverallHistoryscreen> createState() =>
      _TodayOverallHistoryscreenState();
}

class _TodayOverallHistoryscreenState extends State<TodayOverallHistoryscreen> {
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
                      builder: (context) => Agencylist(),
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
                      builder: (context) => Allcustomerforms(),
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
