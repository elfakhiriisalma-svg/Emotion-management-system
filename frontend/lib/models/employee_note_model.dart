class EmployeeNoteModel {
  final int id;
  final String note;
  final int employeeId;
  final String employeeName;
  final int managerId;
  final String managerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeNoteModel({
    required this.id,
    required this.note,
    required this.employeeId,
    required this.employeeName,
    required this.managerId,
    required this.managerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeNoteModel.fromJson(Map<String, dynamic> json) {
    return EmployeeNoteModel(
      id: json['id'] as int,
      note: json['note'] as String,
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
      'note': note,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'managerId': managerId,
      'managerName': managerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}


