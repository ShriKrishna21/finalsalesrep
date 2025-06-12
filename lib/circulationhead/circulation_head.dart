import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/circulationhead/createregionalhead.dart';
import 'package:flutter/material.dart';

class CirculationHead extends StatefulWidget {
  const CirculationHead({super.key});

  @override
  State<CirculationHead> createState() => _CirculationHeadState();
}

class _CirculationHeadState extends State<CirculationHead> {
  final List<Map<String, String>> regionalHeads = [
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
    {"name": "ttttttt", "id": "ttttttt"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const agentProfile(),
                    ));
              },
              child: Icon(
                Icons.person,
                size: MediaQuery.of(context).size.height / 16,
              ))
        ],
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Circulation Head",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: regionalHeads.length,
              itemBuilder: (context, index) {
                final head = regionalHeads[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              head['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text("User ID: ${head['id']}"),
                          ]),
                      const Text(
                        "Role: Regional Head",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => createregionalhead()));
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Regional Head"),
      ),
    );
  }
}
