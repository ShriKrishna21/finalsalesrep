// Model class for User
class Users {
  int? id;
  String? name;
  String? email;
  String? login;
  String? createUid;
  String? unitName;
  String? phone;
  bool? state; // Using bool? internally, but parsed dynamically
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
        id: json['id'] as int?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        login: json['login'] as String?,
        createUid: json['create_uid'] as String?,
        unitName: json['unit_name'] as String?,
        phone: json['phone'] as String?,
        state: json['state'] is bool
            ? json['state'] as bool?
            : json['state'] is String
                ? json['state'].toLowerCase() == 'true'
                : null, // Convert string "true"/"false" to bool, or null for other strings
        panNumber: json['pan_number'] as String?,
        aadharNumber: json['aadhar_number'] as String?,
        role: json['role'] as String?,
        status: json['status'] as String?,
      );
}

// Model class for Response Wrapper
class UserById {
  String? jsonrpc;
  dynamic id;
  Result? result;

  UserById({this.jsonrpc, this.id, this.result});

  factory UserById.fromJson(Map<String, dynamic> json) => UserById(
        jsonrpc: json['jsonrpc'] as String?,
        id: json['id'],
        result: json['result'] != null ? Result.fromJson(json['result']) : null,
      );
}

class Result {
  int? status;
  List<Users>? users;

  Result({this.status, this.users});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        status: json['status'] as int?,
        users: (json['users'] as List?)?.map((e) => Users.fromJson(e)).toList(),
      );
}