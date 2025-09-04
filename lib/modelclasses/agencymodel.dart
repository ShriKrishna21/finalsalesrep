class AgencyModel {
  final AgencyResult? result;

  AgencyModel({this.result});

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      result: json['result'] != null ? AgencyResult.fromJson(json['result']) : null,
    );
  }
}

class AgencyResult {
  final bool success;
  final List<AgencyData> data;

  AgencyResult({required this.success, required this.data});

  factory AgencyResult.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List<dynamic>? ?? [];
    return AgencyResult(
      success: json['success'] ?? false,
      data: dataList.map((item) => AgencyData.fromJson(item)).toList(),
    );
  }
}

class AgencyData {
  final String? id;
  final String? locationName;
  final String? code;
  final String? unit; // Maps to unit_name in the API
  final String? phone; // Handles phone field from API

  AgencyData({this.id, this.locationName, this.code, this.unit, this.phone});

  factory AgencyData.fromJson(Map<String, dynamic> json) {
    // Debug print to inspect the raw JSON for each agency
    // debugPrint("Parsing AgencyData: $json");

    return AgencyData(
      id: json['id']?.toString(),
      locationName: json['location_name'] is String
          ? json['location_name'] as String
          : json['location_name'] == false
              ? null
              : json['location_name']?.toString(),
      code: json['code'] is String
          ? json['code'] as String
          : json['code'] == false
              ? null
              : json['code']?.toString(),
      unit: json['unit_name'] is String
          ? json['unit_name'] as String
          : json['unit_name'] == false
              ? null
              : json['unit_name']?.toString(),
      phone: json['phone'] is String
          ? json['phone'] as String
          : json['phone'] == false
              ? null
              : json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'code': code,
      'unit_name': unit, // Map unit back to unit_name for API payloads
      'phone': phone,
    };
  }
}