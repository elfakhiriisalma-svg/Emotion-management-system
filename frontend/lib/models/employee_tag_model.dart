class EmployeeTagModel {
  final int id;
  final String tag;
  final int employeeId;
  final String employeeName;
  final int managerId;
  final String managerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeTagModel({
    required this.id,
    required this.tag,
    required this.employeeId,
    required this.employeeName,
    required this.managerId,
    required this.managerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeTagModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTagModel(
      id: json['id'] as int,
      tag: json['tag'] as String,
      employeeId: json['employeeId'] as int,
      employeeName: json['employeeName'] as String,
      managerId: json['managerId'] as int,
      managerName: json['managerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tag,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'managerId': managerId,
      'managerName': managerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}


