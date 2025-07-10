class userlogout {
  String? jsonrpc;
  Null id;
  Result? result;

  userlogout({this.jsonrpc, this.id, this.result});

  userlogout.fromJson(Map<String, dynamic> json) {
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
  UserLogin? userLogin;
  String? code;

  Result({this.success, this.message, this.userLogin, this.code});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    userLogin = json['user_login'] != null
        ? UserLogin.fromJson(json['user_login'])
        : null;
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (userLogin != null) {
      data['user_login'] = userLogin!.toJson();
    }
    data['code'] = code;
    return data;
  }
}

class UserLogin {
  String? success;
  int? userId;
  String? userLogin;

  UserLogin({this.success, this.userId, this.userLogin});

  UserLogin.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    userId = json['user_Id'];
    userLogin = json['user_login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['user_Id'] = userId;
    data['user_login'] = userLogin;
    return data;
  }
}
