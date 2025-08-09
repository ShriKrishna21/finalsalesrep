import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';

class TotalStaffAttendance extends StatefulWidget {
  final User user;

  const TotalStaffAttendance({super.key, required this.user});

  @override
  State<TotalStaffAttendance> createState() => _TotalStaffAttendanceState();
}

class _TotalStaffAttendanceState extends State<TotalStaffAttendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total Attendance - ${widget.user.name ?? 'Unknown'}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Total attendance details for ${widget.user.name ?? 'Unknown'}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
