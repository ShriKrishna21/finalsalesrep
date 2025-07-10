class unitwiseusers {
  String? jsonrpc;
  Null id;
  Result? result;

  unitwiseusers({this.jsonrpc, this.id, this.result});

  unitwiseusers.fromJson(Map<String, dynamic> json) {
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
  int? status;
  List<Users>? users;

  Result({this.status, this.users});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? id;
  String? name;
  String? email;
  String? login;
  String? createUid;
  String? unitName;
  String? phone;
  String? state;
  String? panNumber;
  String? aadharNumber;
  String? role;
  String? status;

  Users(
      {this.id,
      this.name,
      this.email,
      this.login,
      this.createUid,
      this.unitName,
      this.phone,
      this.state,
      this.panNumber,
      this.aadharNumber,
      this.role,
      this.status});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    login = json['login'];
    createUid = json['create_uid'];
    unitName = json['unit_name'];
    phone = json['phone'];
    state = json['state'];
    panNumber = json['pan_number'];
    aadharNumber = json['aadhar_number'];
    role = json['role'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['login'] = login;
    data['create_uid'] = createUid;
    data['unit_name'] = unitName;
    data['phone'] = phone;
    data['state'] = state;
    data['pan_number'] = panNumber;
    data['aadhar_number'] = aadharNumber;
    data['role'] = role;
    data['status'] = status;
    return data;
  }
}
