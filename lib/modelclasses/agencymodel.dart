
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
  final String? unit;

  AgencyData({this.id, this.locationName, this.code, this.unit});

  factory AgencyData.fromJson(Map<String, dynamic> json) {
    return AgencyData(
      id: json['id']?.toString(),
      locationName: json['location_name'] as String?,
      code: json['code'] as String?,
      unit: json['unit'] as String?,
    );
  }
}
