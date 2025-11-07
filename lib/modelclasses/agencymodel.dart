class AgencyData {
  final String? id;
  final String? locationName;
  final String? code;
  final String? unit;
  final String? phone;

  AgencyData({this.id, this.locationName, this.code, this.unit, this.phone});

  factory AgencyData.fromJson(Map<String, dynamic> json) {
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
      'unit_name': unit,
      'phone': phone,
    };
  }
}
