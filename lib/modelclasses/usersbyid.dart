// Model class for User
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

  Users({
    this.id,
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
    this.status,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        login: json['login'],
        createUid: json['create_uid'],
        unitName: json['unit_name'],
        phone: json['phone'],
        state: json['state'],
        panNumber: json['pan_number'],
        aadharNumber: json['aadhar_number'],
        role: json['role'],
        status: json['status'],
      );
}

// Model class for Response Wrapper
class UserById {
  String? jsonrpc;
  dynamic id;
  Result? result;

  UserById({this.jsonrpc, this.id, this.result});

  factory UserById.fromJson(Map<String, dynamic> json) => UserById(
        jsonrpc: json['jsonrpc'],
        id: json['id'],
        result: json['result'] != null ? Result.fromJson(json['result']) : null,
      );
}

class Result {
  int? status;
  List<Users>? users;

  Result({this.status, this.users});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        status: json['status'],
        users: (json['users'] as List?)?.map((e) => Users.fromJson(e)).toList(),
      );
}
