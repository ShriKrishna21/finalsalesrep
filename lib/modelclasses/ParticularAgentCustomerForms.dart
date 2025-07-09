class ParticularAgentCustomerForms {
  final Result? result;

  ParticularAgentCustomerForms({this.result});

  factory ParticularAgentCustomerForms.fromJson(Map<String, dynamic> json) {
    return ParticularAgentCustomerForms(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final List<Record>? records;

  Result({this.records});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      records: (json['records'] as List<dynamic>?)
          ?.map((item) => Record.fromJson(item))
          .toList(),
    );
  }
}

class Record {
  final String? familyHeadName;
  final String? date;
  final String? address;
  final String? city;
  final String? pinCode;
  final String? mobileNumber;
  final bool? readNewspaper;
  final bool? eenaduNewspaper;
  final bool? freeOffer15Days;
  final bool? employed;

  Record({
    this.familyHeadName,
    this.date,
    this.address,
    this.city,
    this.pinCode,
    this.mobileNumber,
    this.readNewspaper,
    this.eenaduNewspaper,
    this.freeOffer15Days,
    this.employed,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      familyHeadName: json['family_head_name'] as String?,
      date: json['date'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pinCode: json['pincode']?.toString(),
      mobileNumber: json['mobile_number'] as String?,
      readNewspaper: _parseBool(json['read_newspaper']),
      eenaduNewspaper: _parseBool(json['eenadu_newspaper']),
      freeOffer15Days: _parseBool(json['free_offer_15_days']),
      employed: _parseBool(json['employed']),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return null;
  }
}
