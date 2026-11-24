class Agencyy {
  final int id;
  final String? name;
  final String? code;
  final String? locationName;
  final String? phone;
  final String? unitName;

  Agencyy({
    required this.id,
    this.name,
    this.code,
    this.locationName,
    this.phone,
    this.unitName,
  });

  factory Agencyy.fromJson(Map<String, dynamic> json) {
    return Agencyy(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] == false || json['name'] == null
          ? null
          : json['name'].toString(),
      code: json['code']?.toString(),
      locationName: json['location_name']?.toString(),
      phone: json['phone']?.toString(),
      unitName: json['unit_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'location_name': locationName,
      'phone': phone,
      'unit_name': unitName,
    };
  }

  factory Agencyy.fromMap(Map<String, dynamic> map) {
    return Agencyy(
      id: map['id'] as int,
      name: map['name']?.toString(),
      code: map['code']?.toString(),
      locationName: map['location_name']?.toString(),
      phone: map['phone']?.toString(),
      unitName: map['unit_name']?.toString(),
    );
  }
}