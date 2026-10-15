class AlertModel {
  final int id;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final int employeeId;
  final String employeeName;
  final int managerId;
  final String managerName;

  AlertModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.employeeId,
    required this.employeeName,
    required this.managerId,
    required this.managerName,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as int,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      employeeId: json['employeeId'] as int,
      employeeName: json['employeeName'] as String,
      managerId: json['managerId'] as int,
      managerName: json['managerName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'managerId': managerId,
      'managerName': managerName,
    };
  }
}

