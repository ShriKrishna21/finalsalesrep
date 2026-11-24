
import 'dart:convert';

import 'package:finalsalesrep/common_api_class.dart';
import 'package:finalsalesrep/database/dao/agencydao.dart';
import 'package:finalsalesrep/database/model/agencymodel.dart' show Agencyy;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MasterService {
  final AgencyDao _agencyDao = AgencyDao();

  Future<void> fetchAndSaveAgencyMaster() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('apikey');
    final unitName = prefs.getString('unit') ?? 'unit01';

    if (token == null || token.isEmpty) {
      throw Exception('API token not found');
    }

    final response = await http.post(
      Uri.parse(CommonApiClass.agentagencies),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'params': {
          'token': token,
          'unit_name': unitName,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body);

    if (responseData['result']?['success'] != true) {
      throw Exception('Agency API returned failure');
    }

    final List<dynamic> agencyList =
        responseData['result']['data'] ?? [];

    final agencies = agencyList.map((item) {
      return Agencyy.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();

    await _agencyDao.insertAgencies(agencies);
  }

  Future<List<Agencyy>> loadAgencyMaster() async {
    return await _agencyDao.getAgencies();
  }
}
