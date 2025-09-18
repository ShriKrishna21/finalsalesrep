import 'dart:convert';
import 'dart:convert';


class LocalCustomerForm {
  final int id;
  final Map<String, dynamic> formData;
  final String status;
  final DateTime updatedAt;

  LocalCustomerForm({
    required this.id,
    required this.formData,
    required this.status,
    required this.updatedAt,
  });

  factory LocalCustomerForm.fromDb(Map<String, dynamic> map) {
    return LocalCustomerForm(
      id: map['id'],
      formData: jsonDecode(map['form_data']),
      status: map['status'],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
