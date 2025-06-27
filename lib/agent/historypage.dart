import 'package:finalsalesrep/commonclasses/total_history.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:finalsalesrep/total_history.dart';

class Historypage extends StatefulWidget {
  const Historypage({Key? key}) : super(key: key);

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  List<Records> _records = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final TotalHistory _historyFetcher = TotalHistory();

  @override
  void initState() {
    super.initState();
    loadTotalHistory();
  }

  Future<void> loadTotalHistory() async {
    setState(() => _isLoading = true);

    final result = await _historyFetcher.fetchCustomerForm();
    if (result != null) {
      setState(() {
        _records = result['records'] as List<Records>;
        offerAcceptedCount = result['offer_accepted'] as int;
        offerRejectedCount = result['offer_rejected'] as int;
        alreadySubscribedCount = result['already_subscribed'] as int;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total History (${_records.length})"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
          : _records.isEmpty
              ? const Center(
                  child:
                      Text("No Records Found", style: TextStyle(fontSize: 18)))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatEntity(
                            "Accepted", offerAcceptedCount, Colors.green),
                        _buildStatEntity(
                            "Rejected", offerRejectedCount, Colors.red),
                        _buildStatEntity(
                            "Subscribed", alreadySubscribedCount, Colors.blue),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _records.length,
                      itemBuilder: (c, i) => _buildRecordCard(_records[i]),
                    ),
                  ),
                ]),
    );
  }

  Widget _buildStatEntity(String label, int count, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 4),
        Text("$count",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRecordCard(Records r) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text("FamilyHeadName: ${r.familyHeadName ?? 'N/A'}",
            style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Agent", r.agentName),
                _detailRow("Date", r.date),
                _detailRow("Eenadu Subscribed", r.eenaduNewspaper.toString()),
                _detailRow("Free Offer", r.freeOffer15Days.toString()),
                _detailRow("Reject Reason", r.reasonNotTakingOffer ?? "-"),
                _detailRow("City", r.city),
                // Add more rows as necessary...
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }
}
