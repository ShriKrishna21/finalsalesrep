import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyHistoryScreen extends StatefulWidget {
  const DailyHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DailyHistoryScreen> createState() => _DailyHistoryScreenState();
}

class _DailyHistoryScreenState extends State<DailyHistoryScreen> {
  List<dynamic> _historyData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = false;

  String _searchQuery = "";
  DateTime? _selectedDate;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    fetchHistory(); // auto load
  }

  Future<void> fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apikey') ?? "";

      if (token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No valid token found. Please login.")),
        );
        return;
      }

      final url =
          Uri.parse("https://salesrep.esanchaya.com/api/message/history");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final result = data["result"];
          if (result != null && result["data"] is List) {
            _historyData = result["data"];
            _filteredData = _historyData; // initially same
          } else {
            _historyData = [];
            _filteredData = [];
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Apply search and date filters
  void _applyFilters() {
    List<dynamic> temp = _historyData;

    // Unit name search
    if (_searchQuery.isNotEmpty) {
      temp = temp
          .where((item) => item["unit_name"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Single date filter
    if (_selectedDate != null) {
      String selected = _selectedDate!.toIso8601String().substring(0, 10);
      temp = temp
          .where((item) => (item["date"] ?? "").toString().startsWith(selected))
          .toList();
    }

    // Date range filter
    if (_dateRange != null) {
      temp = temp.where((item) {
        final dateStr = item["date"]?.toString() ?? "";
        if (dateStr.isEmpty) return false;
        try {
          final d = DateTime.parse(dateStr);
          return d.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    setState(() {
      _filteredData = temp;
    });
  }

  /// Open detail link
  Future<void> _openLink(String code) async {
    final url = "https://salesrep.esanchaya.com/view/$code";
    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw "Could not launch $url";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily History"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchHistory,
          )
        ],
      ),
      body: Column(
        children: [
          // 🔎 Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search by Unit Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
            ),
          ),

          // 📅 Date filter buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text("Pick Single Date"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  //This Screen Done By SriHari
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _dateRange = null; // clear range if single picked
                    });
                    _applyFilters();
                  }
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                child: const Text("Pick Date Range"),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                      _selectedDate = null; // clear single if range picked
                    });
                    _applyFilters();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: _filteredData.isEmpty
                      ? const Center(child: Text("No history available"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.black12),
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Unit Name")),
                                DataColumn(label: Text("Agency")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Time")),
                                DataColumn(label: Text("Link")),
                              ],
                              rows: _filteredData.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item["id"]?.toString() ?? "")),
                                  DataCell(Text(
                                      item["unit_name"]?.toString() ?? "")),
                                  DataCell(
                                      Text(item["agency"]?.toString() ?? "")),
                                  DataCell(
                                      Text(item["date"]?.toString() ?? "")),
                                  DataCell(
                                      Text(item["time"]?.toString() ?? "")),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.link,
                                          color: Colors.blue),
                                      onPressed: () {
                                        final code =
                                            item["unic_code"]?.toString() ?? "";
                                        if (code.isNotEmpty) {
                                          _openLink(code);
                                        }
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                ),
        ],
      ),
    );
  }
}
