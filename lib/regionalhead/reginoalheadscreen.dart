import 'dart:convert';
import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/regionalhead/unitwisescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalsalesrep/modelclasses/unitwiseusers.dart';
import 'package:finalsalesrep/agent/agentprofie.dart';
import 'package:finalsalesrep/regionalhead/createunits.dart';

class Reginoalheadscreen extends StatefulWidget {
  const Reginoalheadscreen({super.key});

  @override
  State<Reginoalheadscreen> createState() => _ReginoalheadscreenState();
}

class _ReginoalheadscreenState extends State<Reginoalheadscreen> {
  String? username;
  String? token;
  List<String> unitNames = [];
  List<Users> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchUnits();
  }

  Future<void> loadUserDataAndFetchUnits() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? 'Unknown';
    token = prefs.getString('apikey') ?? '';
    await fetchUnits();
  }

  Future<void> fetchUnits() async {
    final url =
        Uri.parse('https://salesrep.esanchaya.com/api/users_you_created');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "params": {"token": token}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unitData = unitwiseusers.fromJson(data);
        final users = unitData.result?.users ?? [];
        final units = users
            .map((user) => user.unitName ?? '')
            .where((unit) => unit.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        setState(() {
          allUsers = users;
          unitNames = units;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const agentProfile()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.height / 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white),
              ),
              child: Icon(
                Icons.person,
                size: MediaQuery.of(context).size.height / 16,
              ),
            ),
          ),
        ],
        title: Center(
          child: RichText(
            text: TextSpan(
              text: localizations.regionalHead,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "$username\n",
                    style: const TextStyle(color: Colors.black))
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 60),
                  const SizedBox(height: 10),
                  Text(localizations.salesrep),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Switch Language"),
              onTap: () {
                localeProvider.toggleLocale();
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: unitNames.isEmpty
                      ? const Center(child: Text("No units found"))
                      : ListView.builder(
                          itemCount: unitNames.length,
                          itemBuilder: (context, index) {
                            final unitName = unitNames[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(unitName),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UnitUsersScreen(unitName: unitName),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Createincharge()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(localizations.createincharge),
      ),
    );
  }
}
