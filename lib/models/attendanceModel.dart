class AttendanceSummaryModel {
  final int id;
  final String employeeName;
  final String projectName;
  final String fromDate;
  final String toDate;
  final int totalPresent;
  final int totalAbsent;
  final int totalOnLeave;
  final double totalWorkedHours;

  AttendanceSummaryModel({
    required this.id,
    required this.employeeName,
    required this.projectName,
    required this.fromDate,
    required this.toDate,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalOnLeave,
    required this.totalWorkedHours,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    List safeList(dynamic value) => value is List ? value : [];
    final emp = safeList(json['name']);
    final proj = safeList(json['project_id']);

    return AttendanceSummaryModel(
      id: json['id'] ?? 0,
      employeeName: emp.isNotEmpty ? emp[1] : '',
      projectName: proj.isNotEmpty ? proj[1] : '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      totalPresent: json['total_present_days'] ?? 0,
      totalAbsent: json['total_absent_days'] ?? 0,
      totalOnLeave: json['total_on_leave_days'] ?? 0,
      totalWorkedHours:
          double.tryParse(json['total_worked_hours']?.toString() ?? '0') ?? 0,
    );
  }
}
