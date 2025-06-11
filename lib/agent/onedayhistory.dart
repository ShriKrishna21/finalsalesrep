import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/onedayagent.dart';
import 'package:finalsalesrep/modelclasses/onedayhistorymodel.dart';

class Onedayhistory extends StatefulWidget {
  const Onedayhistory({super.key});

  @override
  State<Onedayhistory> createState() => _OnedayhistoryState();
}

class _OnedayhistoryState extends State<Onedayhistory> {
  List<Record> records = [];
  bool _isLoading = true;

  int offerAcceptedCount = 0;
  int offerRejectedCount = 0;
  int alreadySubscribedCount = 0;

  final Onedayagent _onedayagent = Onedayagent();

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
      records = (result['records'] as List<Record>?) ?? [];
      offerAcceptedCount = result['offer_accepted'] ?? 0;
      offerRejectedCount = result['offer_rejected'] ?? 0;
      alreadySubscribedCount = result['already_subscribed'] ?? 0;
      _isLoading = false;
    });
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
                "Count: ${records.length}",
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
            : records.isEmpty
                ? const Center(
                    child: Text(
                      "No Houses Visited Today",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                                "Offer Accepted:", offerAcceptedCount),
                            const SizedBox(height: 8),
                            _buildStatRow(
                                "Offer Rejected:", offerRejectedCount),
                            const SizedBox(height: 8),
                            _buildStatRow(
                                "Already Subscribed:", alreadySubscribedCount),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[400]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: records.length,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return _buildRecordCard(record);
                          },
                        ),
                      ),
                    ],
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
                    _buildDetailRow("Agent Name", record.agentName ?? 'N/A'),
                    _buildDetailRow("Agent Login", record.agentLogin ?? 'N/A'),
                    _buildDetailRow("Date", record.date ?? 'N/A'),
                    _buildDetailRow("Time", record.time ?? 'N/A'),
                    _buildDetailRow(
                        "Family Head Name", record.familyHeadName ?? 'N/A'),
                    _buildDetailRow("Father Name", record.fatherName ?? 'N/A'),
                    _buildDetailRow("Mother Name", record.motherName ?? 'N/A'),
                    _buildDetailRow("Spouse Name", record.spouseName ?? 'N/A'),
                    _buildDetailRow(
                        "House Number", record.houseNumber ?? 'N/A'),
                    _buildDetailRow(
                        "Street Number", record.streetNumber ?? 'N/A'),
                    _buildDetailRow("City", record.city ?? 'N/A'),
                    _buildDetailRow("Pin Code", record.pinCode ?? 'N/A'),
                    _buildDetailRow("Address", record.address ?? 'N/A'),
                    _buildDetailRow(
                        "Mobile Number", record.mobileNumber ?? 'N/A'),
                    _buildDetailRow("Eenadu Newspaper",
                        "${record.eenaduNewspaper ?? 'N/A'}"),
                    _buildDetailRow("Feedback to Improve",
                        record.feedbackToImproveEenaduPaper ?? 'N/A'),
                    _buildDetailRow(
                        "Read Newspaper", "${record.readNewspaper ?? 'N/A'}"),
                    _buildDetailRow(
                        "Current Newspaper", record.currentNewspaper ?? 'N/A'),
                    _buildDetailRow("Reason for not taking Eenadu",
                        record.reasonForNotTakingEenaduNewsPaper ?? 'N/A'),
                    _buildDetailRow(
                        "Reason not reading", record.reasonNotReading ?? 'N/A'),
                    _buildDetailRow("Free Offer 15 Days",
                        "${record.freeOffer15Days ?? 'N/A'}"),
                    _buildDetailRow("Reason not taking offer",
                        record.reasonNotTakingOffer ?? 'N/A'),
                    _buildDetailRow("Employed", "${record.employed ?? 'N/A'}"),
                    _buildDetailRow("Job Type", "${record.jobType ?? 'N/A'}"),
                    _buildDetailRow(
                        "Job Type One", "${record.jobTypeOne ?? 'N/A'}"),
                    _buildDetailRow(
                        "Job Profession", record.jobProfession ?? 'N/A'),
                    _buildDetailRow(
                        "Job Designation", record.jobDesignation ?? 'N/A'),
                    _buildDetailRow(
                        "Company Name", record.companyName ?? 'N/A'),
                    _buildDetailRow("Profession", record.profession ?? 'N/A'),
                    _buildDetailRow("Job Working State",
                        "${record.jobWorkingState ?? 'N/A'}"),
                    _buildDetailRow("Job Working Location",
                        "${record.jobWorkingLocation ?? 'N/A'}"),
                    _buildDetailRow("Job Designation One",
                        record.jobDesignationOne ?? 'N/A'),
                    _buildDetailRow("Latitude", record.latitude ?? 'N/A'),
                    _buildDetailRow("Longitude", record.longitude ?? 'N/A'),
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
