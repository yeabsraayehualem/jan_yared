enum LeaveStatus { approved, pending, rejected }

enum LeaveType { annual, sick, personal }

class LeaveRequest {
  final LeaveType type;
  final LeaveStatus status;
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final String project;
  final DateTime submittedDate;

  LeaveRequest({
    required this.type,
    required this.status,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.project,
    required this.submittedDate,
  });
}

