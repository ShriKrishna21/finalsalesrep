import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/modelclasses/usersunit.dart';
import 'package:finalsalesrep/regionalhead/customerformsscreen.dart';
import 'package:finalsalesrep/regionalhead/todaycustomerformscreen.dart';
import 'package:finalsalesrep/regionalhead/unitwisepromoters.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitUsersScreen extends StatefulWidget {
  final String unitName;

  const UnitUsersScreen({
    super.key,
    required this.unitName,
  });

  @override
  State<UnitUsersScreen> createState() => _UnitUsersScreenState();
}

class _UnitUsersScreenState extends State<UnitUsersScreen> {
  bool isLoading = true;
  List<Data> users = [];
  bool showAgents = false;

  @override
  void initState() {
    super.initState();
    fetchUsersInUnit();
  }

  Future<void> fetchUsersInUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('apikey') ?? '';

    final url = Uri.parse('https://salesrep.esanchaya.com/unit/users');

    final body = jsonEncode({
      "params": {
        "token": token,
        "unit_name": widget.unitName,
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final usersData = usersinunit.fromJson(decoded);
        setState(() {
          users = usersData.result?.data ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final otherUsers =
        users.where((user) => user.role?.toLowerCase() != 'agent').toList();
    final agentUsers =
        users.where((user) => user.role?.toLowerCase() == 'agent').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Users in ${widget.unitName}'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(child: Text(localizations.nousersfoundinthisunit))
              : ListView(
                  children: [
                    // Show non-agent users directly
                    ...otherUsers.map((user) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.name ?? "No Name"),
                            subtitle: Text(
                                "${user.role ?? "No Role"} - ${user.email ?? ""}"),
                          ),
                        )),

                    // Agent container
                   if (agentUsers.isNotEmpty)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      child: ExpansionTile(
        title: Text(
          "Promoters",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: false,
        children: agentUsers.map((user) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.name ?? "No Name"),
            subtitle:
                Text("${user.role ?? "No Role"} - ${user.email ?? ""}"),
           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => unitwisepromoters(
        id: user.id ?? 0, // match the constructor parameter name
        name: user.name ?? "No Name",
      ),
    ),
  );
},

          );
        }).toList(),
      ),
    ),
  ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Customerformsscreen(unitName: widget.unitName),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.lightBlue[50],
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              "Total Customer Forms of Unit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Todaycustomerformscreen(unitName: widget.unitName),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.lightBlue[50],
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              "Today Customer Forms of Unit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
