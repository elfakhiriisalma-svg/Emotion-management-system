class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final DateTime? createdAt;
  
  // Employee profile fields
  final int? age;
  final String? gender; // MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY
  final String? profilePicture;
  final DateTime? lastConnectedDate;
  
  // Manager profile fields
  final String? specialty;
  final List<int>? assignedEmployeeIds;
  final int? assignedEmployeesCount;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
    this.age,
    this.gender,
    this.profilePicture,
    this.lastConnectedDate,
    this.specialty,
    this.assignedEmployeeIds,
    this.assignedEmployeesCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      profilePicture: json['profilePicture'] as String?,
      lastConnectedDate: json['lastConnectedDate'] != null
          ? DateTime.parse(json['lastConnectedDate'] as String)
          : null,
      specialty: json['specialty'] as String?,
      assignedEmployeeIds: json['assignedEmployeeIds'] != null
          ? List<int>.from(json['assignedEmployeeIds'] as List)
          : null,
      assignedEmployeesCount: json['assignedEmployeesCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'age': age,
      'gender': gender,
      'profilePicture': profilePicture,
      'lastConnectedDate': lastConnectedDate?.toIso8601String(),
      'specialty': specialty,
      'assignedEmployeeIds': assignedEmployeeIds,
      'assignedEmployeesCount': assignedEmployeesCount,
    };
  }
  
  bool get isEmployee => role == 'EMPLOYEE';
  bool get isManager => role == 'MANAGER';
}

