class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String phone;
  final int age;
  final String role;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.age,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'age': age,
      'role': "Customer",
    };
  }
}
