class unitwiseusers {
  String? jsonrpc;
  Null? id;
  Result? result;

  unitwiseusers({this.jsonrpc, this.id, this.result});

  unitwiseusers.fromJson(Map<String, dynamic> json) {
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
  int? status;
  List<Users>? users;

  Result({this.status, this.users});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['login'] = this.login;
    data['create_uid'] = this.createUid;
    data['unit_name'] = this.unitName;
    data['phone'] = this.phone;
    data['state'] = this.state;
    data['pan_number'] = this.panNumber;
    data['aadhar_number'] = this.aadharNumber;
    data['role'] = this.role;
    data['status'] = this.status;
    return data;
  }
}
