import 'package:finalsalesrep/circulationhead/createregionalhead.dart';
import 'package:flutter/material.dart';

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("admin dashboard"),
      ),
      body: const Column(),
    );
  }
}
