import 'package:finalsalesrep/unit/circulationincharge/toaday_customerforms_agent.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_customerform_agency.dart';
import 'package:finalsalesrep/unit/today_customerforms_agencylist.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/today_staff_attendance.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_staff_attendance.dart';

class AgentDetailsScreen extends StatefulWidget {
  final User user;

  const AgentDetailsScreen({super.key, required this.user});

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Staff: ${widget.user.name ?? 'Unknown'}",
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildBlackWhiteButton("Staff Today's Attendance", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TodayStaffAttendance(user: widget.user),
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildBlackWhiteButton("Staff Total Attendance", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TotalStaffAttendance(user: widget.user),
              ),
            );
          }),
                    const SizedBox(height: 20),

          _buildBlackWhiteButton("Today customer forms", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => todaycustomerformagencylist(user: widget.user),
              ),
            );
          }),
                    const SizedBox(height: 20),

            _buildBlackWhiteButton("Total customer forms", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TotalCustomerformAgency(user: widget.user),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBlackWhiteButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
              vertical: MediaQuery.of(context).size.height * 0.015,
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
