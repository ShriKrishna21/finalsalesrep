import 'package:finalsalesrep/regionalhead/unittodaycustomerforms.dart';
import 'package:finalsalesrep/regionalhead/unittodaystaffattendance.dart';
import 'package:finalsalesrep/regionalhead/unittotalcustomerforms.dart';

import 'package:finalsalesrep/regionalhead/unittotalstaffattendance.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/unit/circulationincharge/toaday_customerforms_agent.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_customerform_agency.dart';
import 'package:finalsalesrep/unit/today_customerforms_agencylist.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/noofagents.dart';
import 'package:finalsalesrep/unit/circulationincharge/today_staff_attendance.dart';
import 'package:finalsalesrep/unit/circulationincharge/total_staff_attendance.dart';

class unitwisepromoters extends StatefulWidget {
  final int id;
  final String name;

  const unitwisepromoters({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<unitwisepromoters> createState() => _unitwisepromotersState();
}

class _unitwisepromotersState extends State<unitwisepromoters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Staff: ${widget.name} (${widget.id})",
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildBlackWhiteButton("${widget.name} Total Attendance", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => unittotalstaffattendance(userid: widget.id),
              ),
            );
          }),
          SizedBox(height: 20),
          _buildBlackWhiteButton("${widget.name} Today Attendance", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => unittodaystaffattendance(userid: widget.id),
              ),
            );
          }),
          SizedBox(height: 20),
          _buildBlackWhiteButton("${widget.name} Today Customerforms", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Unittodaycustomerforms(userid: widget.id),
              ),
            );
          }),
          SizedBox(height: 20),
          _buildBlackWhiteButton("${widget.name} Total Customerforms", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => unittotalcustomerforms(userid: widget.id),
              ),
            );
          }),
          SizedBox(height: 20),
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
