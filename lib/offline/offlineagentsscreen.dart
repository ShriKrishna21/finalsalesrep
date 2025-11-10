// lib/offline/offline_agents_screen.dart
import 'package:finalsalesrep/offline/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/l10n/app_localization.dart';

class OfflineAgentsScreen extends StatefulWidget {
  const OfflineAgentsScreen({super.key});

  @override
  State<OfflineAgentsScreen> createState() => _OfflineAgentsScreenState();
}

class _OfflineAgentsScreenState extends State<OfflineAgentsScreen> {
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DBHelper().getAllPending();
    setState(() => _pending = data);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Created Staff"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _pending.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No offline staff", style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _pending.length,
                itemBuilder: (ctx, i) {
                  final agent = _pending[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text("${i + 1}"),
                      ),
                      title: Text(agent['name']),
                      subtitle: Text("${agent['phone']} • ${agent['email']}"),
                      trailing: Chip(
                        label: Text("Pending", style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}