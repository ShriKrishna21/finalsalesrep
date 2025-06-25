import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:flutter/material.dart';

class historypage extends StatefulWidget {
  const historypage({super.key});

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {
  int offerAccepted = 0;
  int offerRejected = 0;
  int alreadySubscribed = 0;
  int totalRecords = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTodayHistory();
  }

  Future<void> fetchTodayHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await Onedayagent().fetchOnedayHistory();

    if (result.containsKey('error')) {
      setState(() {
        errorMessage = result['error'];
        isLoading = false;
      });
    } else {
      setState(() {
        offerAccepted = result['offer_accepted'] ?? 0;
        offerRejected = result['offer_rejected'] ?? 0;
        alreadySubscribed = result['already_subscribed'] ?? 0;
        totalRecords = (result['records'] as List).length;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Visit Summary'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatRow("✔ Offer Accepted", offerAccepted),
                    _buildStatRow("✖ Offer Rejected", offerRejected),
                    _buildStatRow("📰 Already Subscribed", alreadySubscribed),
                    _buildStatRow("📄 Total Records", totalRecords),
                    const SizedBox(height: 24),
                    const Text(
                      "Note: These stats reflect your visits today.",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
