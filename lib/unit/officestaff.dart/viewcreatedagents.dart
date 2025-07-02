import 'package:flutter/material.dart';

class Viewcreatedagents extends StatefulWidget {
  const Viewcreatedagents({super.key});

  @override
  State<Viewcreatedagents> createState() => _ViewcreatedagentsState();
}

class _ViewcreatedagentsState extends State<Viewcreatedagents> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title: Text("created agents"),
      ),
    );
  }
}