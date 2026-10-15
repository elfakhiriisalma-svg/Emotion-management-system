class AuthResponseModel {
  final String token;
  final String type;
  final int id;
  final String fullName;
  final String email;
  final String role;

  AuthResponseModel({
    required this.token,
    required this.type,
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      type: json['type'] as String,
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }
}

