import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/total_history.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});
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

  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final result = await _historyFetcher.fetchCustomerForm();
    if (result != null) {
      final all = result['records'] as List<Records>;
      final accepted = result['offer_accepted'] as int;
      final rejected = result['offer_rejected'] as int;
      final subscribed = result['already_subscribed'] as int;

      var filtered = all;
      if (_selectedRange != null) {
        final s = _selectedRange!.start;
        final e = _selectedRange!.end.add(const Duration(days: 1));
        filtered = all.where((r) {
          final dt = DateTime.tryParse(r.date ?? '');
          return dt != null &&
              dt.isAfter(s.subtract(const Duration(milliseconds: 1))) &&
              dt.isBefore(e);
        }).toList();
      }

      setState(() {
        _records = filtered;
        offerAcceptedCount = accepted;
        offerRejectedCount = rejected;
        alreadySubscribedCount = subscribed;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total History (${_records.length})"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          _selectedRange == null
                              ? "All Dates"
                              : "${_selectedRange!.start.toLocal().toString().split(' ')[0]} → ${_selectedRange!.end.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 🎯 Moved Fetch button below the date picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.filter_center_focus),
                label: const Text("Fetch customer forms"),
                onPressed: _fetchHistory,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),

          if (_isLoading) const LinearProgressIndicator(),
          if (!_isLoading && _records.isEmpty) ...[
            const Expanded(child: Center(child: Text("No Records Found", style: TextStyle(fontSize: 18)))),
          ],
          if (!_isLoading && _records.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat("Accepted", offerAcceptedCount, Colors.green),
                  _buildStat("Rejected", offerRejectedCount, Colors.red),
                  _buildStat("Subscribed", alreadySubscribedCount, Colors.blue),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _records.length,
                itemBuilder: (c, i) => _buildRecordCard(_records[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text("$count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    ],
  );

  Widget _buildRecordCard(Records r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          "Family: ${r.familyHeadName ?? 'N/A'}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Agent", r.agentName),
                _detailRow("Date", r.date),
                _detailRow("Subscribed", _formatBool(r.eenaduNewspaper)),
                _detailRow("Free Offer", _formatBool(r.freeOffer15Days)),
                _detailRow("Read Newspaper", _formatBool(r.readNewspaper)),
                _detailRow("Reject Reason", r.reasonNotTakingOffer),
                _detailRow("City", r.city),
                _detailRow("Mobile", r.mobileNumber),
                _detailRow("Address", r.address),
                _detailRow("Employed", _formatBool(r.employed)),
                _detailRow("Job Type", _formatBool(r.jobType)),
                _detailRow("Working in State", _formatBool(r.jobWorkingState)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  String _formatBool(bool? v) {
    if (v == true) return 'Yes';
    if (v == false) return 'No';
    return 'N/A';
  }
}
