class approveagent {
  String? jsonrpc;
  Null? id;
  Result? result;

  approveagent({this.jsonrpc, this.id, this.result});

  approveagent.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  String? success;
  int? userId;
  String? code;

  Result({this.success, this.userId, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    userId = json['user_id'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['user_id'] = this.userId;
    data['code'] = this.code;
    return data;
  }
}