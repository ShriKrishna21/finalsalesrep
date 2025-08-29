import 'package:finalsalesrep/modelclasses/agencymodel.dart';
import 'package:finalsalesrep/modelclasses/customerformsunitwise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class AgencyTotalCustomerforms extends StatefulWidget {
  final String agencyName;

  const AgencyTotalCustomerforms({super.key, required this.agencyName});

  @override
  State<AgencyTotalCustomerforms> createState() =>
      _AgencyTotalCustomerformsState();
}

class _AgencyTotalCustomerformsState extends State<AgencyTotalCustomerforms> {
  List<Records> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchCustomerForms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey');
    final unit = prefs.getString('unit');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String apiUrl =
        'https://salesrep.esanchaya.com/api/customer_forms_filtered';
    final Map<String, dynamic> params = {
      'token': token,
      'from_date': '',
      'to_date': '',
      'unit_name': unit,
      'order': 'asc',
    };

    try {
      print('Request params: ${jsonEncode({'params': params})}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'params': params}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final AllCustomerForms data =
            AllCustomerForms.fromJson(jsonDecode(response.body));
        if (data.result?.success == true && data.result?.records != null) {
          setState(() {
            _records = data.result!.records!
                .where((record) =>
                    record.agency != null &&
                    record.agency!.trim().toLowerCase() ==
                        widget.agencyName.toLowerCase())
                .toList();
          });
          print('Filtered records count: ${_records.length}');
        } else {
          setState(() {
            _errorMessage = data.result?.code ?? 'No records found';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomerForms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.agencyName} '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchCustomerForms,
              child: const Text('Refresh Forms'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_records.isEmpty)
              Text('No records available for ${widget.agencyName}')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(record.familyHeadName ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Agent: ${record.agentName ?? 'N/A'}'),
                            Text('City: ${record.city ?? 'N/A'}'),
                            Text('Mobile: ${record.mobileNumber ?? 'N/A'}'),
                            Text('Date: ${record.date ?? 'N/A'}'),
                            Text('Agency: ${record.agency ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}