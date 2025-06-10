import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalsalesrep/modelclasses/coustmersinfobyid.dart';

class Particularuser {
  Future<Map<String, dynamic>?> fetchCustomerFormsByIdWithReturn() async {
    try {
      // Replace with your actual endpoint
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));

      // Log the status and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Try parsing the JSON response
        try {
          final jsonData = jsonDecode(response.body);
          final result = CustomerFormsInfoById.fromJson(jsonData);
          final List<Record> records = result.result?.records ?? [];

          int accepted = 0;
          int rejected = 0;
          int subscribed = 0;

          for (var record in records) {
            if (record.freeOffer15Days == true) accepted++;
            if (record.freeOffer15Days == false) rejected++;
            if (record.eenaduNewspaper == true) subscribed++;
          }

          return {
            'records': records,
            'offer_accepted': accepted,
            'offer_rejected': rejected,
            'already_subscribed': subscribed,
          };
        } catch (e) {
          print('Error parsing JSON: $e');
          return null;
        }
      } else {
        // If the API response is not 200, log the status code
        throw Exception('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any error during the API call and log it
      print('Error during API call: $e');
      return null;
    }
  }
}
