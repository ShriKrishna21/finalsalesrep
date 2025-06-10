import 'package:flutter/material.dart';
import 'package:finalsalesrep/commonclasses/particularuser.dart' show Particularuser;
import 'package:finalsalesrep/modelclasses/coustmersinfobyid.dart';
class Particularagent extends StatefulWidget {
  const Particularagent({super.key});

  @override
  State<Particularagent> createState() => _ParticularagentState();
}

class _ParticularagentState extends State<Particularagent> {
  List<Record> _records = [];
  int _accepted = 0;
  int _rejected = 0;
  int _subscribed = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _noData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final particularUser = Particularuser();
    final result = await particularUser.fetchCustomerFormsByIdWithReturn();

    if (result != null) {
      setState(() {
        _records = result['records'];
        _accepted = result['offer_accepted'];
        _rejected = result['offer_rejected'];
        _subscribed = result['already_subscribed'];
        _isLoading = false;

        // Handle no data scenario
        if (_records.isEmpty) {
          _noData = true;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Particular Agent")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Error loading data. Please try again later.'))
              : _noData
                  ? const Center(child: Text('No data available.'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Accepted: $_accepted, Rejected: $_rejected, Subscribed: $_subscribed"),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(12),
                                  title: Text(record.name ?? "No Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Phone: ${record.phone ?? 'N/A'}"),
                                      Text(
                                          "Offer: ${record.freeOffer15Days == true ? 'Accepted' : 'Not Accepted'}"),
                                      Text(
                                          "Reason: ${record.reasonNotTakingOffer ?? 'N/A'}"),
                                    ],
                                  ),
                                  trailing: record.eenaduNewspaper == true
                                      ? Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : Icon(Icons.cancel, color: Colors.red),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
