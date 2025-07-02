class createUserModel {
  String? jsonrpc;
  dynamic id;
  Result? result;

  createUserModel({this.jsonrpc, this.id, this.result});

  createUserModel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  bool? success;
  String? message; // assuming message or any additional info

  Result({this.success, this.message});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message']; // optional field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}
