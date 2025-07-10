class coustmerform {
  String? jsonrpc;
  Null id;
  Result? result;

  coustmerform({this.jsonrpc, this.id, this.result});

  coustmerform.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jsonrpc'] = jsonrpc;
    data['id'] = id;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  bool? success;
  String? message;
  int? customerId;
  String? code;

  Result({this.success, this.message, this.customerId, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    customerId = json['customer_id'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['customer_id'] = customerId;
    data['code'] = code;
    return data;
  }
}
