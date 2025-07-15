import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';
import 'package:provider/provider.dart';

class Onedayhistory extends StatefulWidget {
  const Onedayhistory({super.key});

  @override
  State<Onedayhistory> createState() => _OnedayhistoryState();
}

class _OnedayhistoryState extends State<Onedayhistory> {
  List<Record> records = [];
  List<Record> filteredRecords = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOnedayHistory();
  }

  Future<void> loadOnedayHistory() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _onedayagent.fetchOnedayHistory();

    setState(() {
      final fetchedRecords = (result['records'] as List<Record>?) ?? [];
      records = fetchedRecords.reversed.toList();
      filteredRecords = List.from(records);

      offerAcceptedCount = result['offer_accepted'] ?? 0;
      offerRejectedCount = result['offer_rejected'] ?? 0;
      alreadySubscribedCount = result['already_subscribed'] ?? 0;
      _isLoading = false;
    });
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecords = List.from(records);
      } else {
        final lowerQuery = query.toLowerCase();
        filteredRecords = records.where((record) {
          final id = record.id?.toString().toLowerCase() ?? '';
          final name = record.agentName?.toLowerCase() ?? '';
          final familyHead = record.familyHeadName?.toLowerCase() ?? '';

          return id.contains(lowerQuery) ||
              name.contains(lowerQuery) ||
              familyHead.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        title: Row(
          children: [
            const Text(
              "Houses Visited Today",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Count: ${filteredRecords.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
            : RefreshIndicator(
                onRefresh: loadOnedayHistory,
                child: filteredRecords.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 300),
                          Center(
                            child: Text(
                              "No Houses Visited Today",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _searchController,
                                  onChanged: _filterRecords,
                                  decoration: InputDecoration(
                                    hintText: "Search by Name or ID",
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                    "Offer Accepted:", offerAcceptedCount),
                                const SizedBox(height: 8),
                                _buildStatRow(
                                    "Offer Rejected:", offerRejectedCount),
                                const SizedBox(height: 8),
                                _buildStatRow("Already Subscribed:",
                                    alreadySubscribedCount),
                                const SizedBox(height: 16),
                                Divider(color: Colors.grey[400]),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredRecords.length,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                return _buildRecordCard(record);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F51B5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(Record record) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              "Record ID: ${record.id ?? "N/A"}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF3F51B5),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        localizations.agentName, record.agentName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.agentlogin, record.agentLogin ?? 'N/A'),
                    _buildDetailRow(localizations.date, record.date ?? 'N/A'),
                    _buildDetailRow(localizations.time, record.time ?? 'N/A'),
                    _buildDetailRow(localizations.familyheadname,
                        record.familyHeadName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.fathersname, record.fatherName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.mothername, record.motherName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.spousename, record.spouseName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.housenumber, record.houseNumber ?? 'N/A'),
                    _buildDetailRow(localizations.streetnumber,
                        record.streetNumber ?? 'N/A'),
                    _buildDetailRow(localizations.city, record.city ?? 'N/A'),
                    _buildDetailRow(
                        localizations.pincode, record.pinCode ?? 'N/A'),
                    _buildDetailRow(
                        localizations.address, record.address ?? 'N/A'),
                    _buildDetailRow(localizations.mobilenumber,
                        record.mobileNumber ?? 'N/A'),
                    _buildDetailRow(localizations.eenadunewspaper,
                        _formatBool(record.eenaduNewspaper)),
                    _buildDetailRow(localizations.feedbacktoimprove,
                        record.feedbackToImproveEenaduPaper ?? 'N/A'),
                    _buildDetailRow(localizations.readnewspaper,
                        _formatBool(record.readNewspaper)),
                    _buildDetailRow(localizations.currentnewspaper,
                        record.currentNewspaper ?? 'N/A'),
                    _buildDetailRow(localizations.reasonfornottakingeenadu,
                        record.reasonForNotTakingEenaduNewsPaper ?? 'N/A'),
                    _buildDetailRow(localizations.reasonnotreading,
                        record.reasonNotReading ?? 'N/A'),
                    _buildDetailRow(localizations.freeoffer,
                        _formatBool(record.freeOffer15Days)),
                    _buildDetailRow(localizations.reasonfornottakingoffer,
                        record.reasonNotTakingOffer ?? 'N/A'),
                    _buildDetailRow(
                        localizations.employed, _formatBool(record.employed)),
                    _buildDetailRow(
                        localizations.jobtype, record.jobType ?? 'N/A'),
                    _buildDetailRow(
                        localizations.jobtypeone, record.jobTypeOne ?? 'N/A'),
                    _buildDetailRow(localizations.jobprofession,
                        record.jobProfession ?? 'N/A'),
                    _buildDetailRow(localizations.jobdesignation,
                        record.jobDesignation ?? 'N/A'),
                    _buildDetailRow(
                        localizations.companyname, record.companyName ?? 'N/A'),
                    _buildDetailRow(
                        localizations.profession, record.profession ?? 'N/A'),
                    _buildDetailRow(localizations.jobWorkingstate,
                        record.jobWorkingState ?? 'N/A'),
                    _buildDetailRow(localizations.jobworkinglocation,
                        record.jobWorkingLocation ?? 'N/A'),
                    _buildDetailRow(localizations.jobdesignationone,
                        record.jobDesignationOne ?? 'N/A'),
                    _buildDetailRow(
                        localizations.latitude, record.latitude ?? 'N/A'),
                    _buildDetailRow(
                        localizations.longitude, record.longitude ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
