// file: sync_manager.dart

import 'package:finalsalesrep/offline/localdb.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final LocalDb _localDb = LocalDb();

  Future<void> syncPendingForms(String agentApiToken) async {
    List<Map<String, dynamic>> pendings = await _localDb.getPendingForms();
    for (var map in pendings) {
      int id = map['id'] as int;
      String formDataString = map['form_data'] as String;
      Map<String, dynamic> formData = jsonDecode(formDataString);

      try {
        // Assuming your API endpoint for form submission is like this:
        final response = await http.post(
          Uri.parse('https://salesrep.esanchaya.com/api/customer_form'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "params": {
              ...formData,
              "token": agentApiToken,
              // include any extra required auth fields
            }
          }),
        );
        if (response.statusCode == 200) {
          // parse response, check for code == "200" etc
          final resp = jsonDecode(response.body);
          // Let's assume you check for `resp['result']['code'] == "200"`
          if (resp['result'] != null && resp['result']['code'] == "200") {
            await _localDb.markFormSent(id);
          } else {
            // maybe leave it pending, possibly mark error
          }
        } else {
          // server error: leave as pending
        }
      } catch (e) {
        // network error etc => leave pending
      }
    }
  }
}
