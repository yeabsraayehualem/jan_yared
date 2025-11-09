class UserModel {
  final String fullName;
  final String email;
  final int employeeId;
  final String? phone;

  UserModel({
    required this.fullName,
    required this.email,
    required this.employeeId,
    this.phone
  });

 // In models/user_model.dart
Map<String, dynamic> toJson() => {
  'fullName': fullName,
  'email': email,
  'phone': phone,
  'employee_id': employeeId,
};

factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  fullName: json['fullName'] ?? '',
  email: json['email'] ?? '',
  phone: json['phone'] ?? '',
   employeeId: json['employee_id'] ?? 0,
);
}
