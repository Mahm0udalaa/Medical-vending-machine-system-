class LoginResponseModel {
  final int id;
  final String role;
  final String token;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final DateTime refreshTokenExpiresAt;

  LoginResponseModel({
    required this.id,
    required this.role,
    required this.token,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        id: json['id'],
        role: json['role'],
        token: json['token'],
        refreshToken: json['refreshToken'],
        tokenExpiresAt: DateTime.parse(json['tokenExpiresAt']),
        refreshTokenExpiresAt: DateTime.parse(json['refreshTokenExpiresAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'token': token,
        'refreshToken': refreshToken,
        'tokenExpiresAt': tokenExpiresAt.toIso8601String(),
        'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
      };
}