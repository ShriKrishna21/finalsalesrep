import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/total_history.dart';
import 'package:finalsalesrep/modelclasses/historymodel.dart';
import 'package:provider/provider.dart';

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
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.totalhistory} (${_records.length})'),
        flexibleSpace: Container(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
          : _records.isEmpty
              ? const Center(
                  child:
                      Text("No Records Found", style: TextStyle(fontSize: 18)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatEntity(localizations.accepted,
                              offerAcceptedCount, Colors.green),
                          _buildStatEntity(localizations.rejected,
                              offerRejectedCount, Colors.red),
                          _buildStatEntity(localizations.subscribed,
                              alreadySubscribedCount, Colors.blue),
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
                  ],
                ),
    );
  }

  Widget _buildStatEntity(String label, int count, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                _detailRow("Eenadu Subscribed", _formatBool(r.eenaduNewspaper)),
                _detailRow("Free Offer", _formatBool(r.freeOffer15Days)),
                _detailRow("Read Newspaper", _formatBool(r.readNewspaper)),
                _detailRow("Reject Reason", r.reasonNotTakingOffer),
                _detailRow("City", r.city),
                _detailRow("Mobile", r.mobileNumber),
                _detailRow("Address", r.address),
                _detailRow("Employed", _formatBool(r.employed)),
                _detailRow("Job Type", _formatBool(r.jobType)),
                _detailRow("Working in State", _formatBool(r.jobWorkingState)),
                // Add more fields if needed...
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

  /// Helper to convert bool? to "Yes", "No", or "N/A"
  String _formatBool(bool? value) {
    if (value == true) return 'Yes';
    if (value == false) return 'No';
    return 'N/A';
  }
}
