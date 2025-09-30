import 'package:flutter/material.dart';
import 'package:finalsalesrep/offline/attendance/localdbattendance.dart';

class OfflineAttendanceView extends StatefulWidget {
  const OfflineAttendanceView({super.key});

  @override
  State<OfflineAttendanceView> createState() => _OfflineAttendanceViewState();
}

class _OfflineAttendanceViewState extends State<OfflineAttendanceView> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await LocalDbattendance.instance.getAllActions();

    // 🔹 filter out "synced"
    final filtered = list.where((row) => row['status'] != 'synced').toList();

    setState(() {
      _items = filtered;
      _loading = false;
    });
  }

  String _format(String? iso) {
    if (iso == null || iso.isEmpty) return "--";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
             "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'failed':  return Colors.red;
      default:        return Colors.grey;
    }
  }

  IconData _icon(String action) {
    return action == 'startWork' ? Icons.play_arrow : Icons.stop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Attendance")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text("No offline attendance saved"))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final row = _items[i];
                      final action = row['action'] as String? ?? '--';
                      final createdAt = row['created_at'] as String?;
                      final status = row['status'] as String? ?? 'pending';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(status).withOpacity(0.15),
                          child: Icon(_icon(action), color: _statusColor(status)),
                        ),
                        title: Text(action == 'startWork' ? "Start Work" : "Stop Work"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Created: ${_format(createdAt)}"),
                            Text("Status: $status", style: TextStyle(color: _statusColor(status))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
