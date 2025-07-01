class UnitWiseFormsResponse {
  final UnitWiseFormsResult? result;

  UnitWiseFormsResponse({this.result});

  factory UnitWiseFormsResponse.fromJson(Map<String, dynamic> json) {
    return UnitWiseFormsResponse(
      result: json['result'] != null ? UnitWiseFormsResult.fromJson(json['result']) : null,
    );
  }
}

class UnitWiseFormsResult {
  final List<UnitCustomerForm>? customerforms;

  UnitWiseFormsResult({this.customerforms});

  factory UnitWiseFormsResult.fromJson(Map<String, dynamic> json) {
    return UnitWiseFormsResult(
      customerforms: (json['customerforms'] as List?)
          ?.map((e) => UnitCustomerForm.fromJson(e))
          .toList(),
    );
  }
}

class UnitCustomerForm {
  final int? id;
  final String? customerName;

  UnitCustomerForm({
    this.id,
    this.customerName,
  });

  factory UnitCustomerForm.fromJson(Map<String, dynamic> json) {
    return UnitCustomerForm(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      customerName: json['customer_name'],
    );
  }
}
