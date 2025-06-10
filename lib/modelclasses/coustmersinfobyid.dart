class CustomerFormsInfoById {
  final Result? result;

  CustomerFormsInfoById({this.result});

  factory CustomerFormsInfoById.fromJson(Map<String, dynamic> json) {
    return CustomerFormsInfoById(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}
class Result {
  final List<Record> records;

  Result({required this.records});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      records: (json['records'] as List)
          .map((item) => Record.fromJson(item))
          .toList(),
    );
  }
}

class Record {
  final String? name;
  final String? phone;
  final bool? eenaduNewspaper;
  final bool? freeOffer15Days;
  final String? reasonNotTakingOffer;

  Record({
    this.name = "Unknown",  // Default value
    this.phone = "N/A",     // Default value
    this.eenaduNewspaper,
    this.freeOffer15Days,
    this.reasonNotTakingOffer = "N/A",  // Default value
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      name: json['name'],
      phone: json['phone'],
      eenaduNewspaper: json['eenadu_newspaper'],
      freeOffer15Days: json['free_offer_15_days'],
      reasonNotTakingOffer: json['reason_not_taking_offer'],
    );
  }
}