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
  String? message; // assuming message or any additional info

  Result({this.success, this.message});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message']; // optional field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}
