class ApproveAgent {
  String? jsonrpc;
  dynamic id;
  Result? result;

  ApproveAgent({this.jsonrpc, this.id, this.result});

  factory ApproveAgent.fromJson(Map<String, dynamic> json) {
    return ApproveAgent(
      jsonrpc: json['jsonrpc'],
      id: json['id'],
      result:
          json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      if (result != null) 'result': result!.toJson(),
    };
  }
}

class Result {
  bool? success;
  int? userId;
  String? message;

  Result({this.success, this.userId, this.message});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      success: json['success'] == true || json['success'] == 'true',
      userId: json['user_id'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user_id': userId,
      'message': message,
    };
  }
}
