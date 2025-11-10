enum LeaveStatus { approved, pending, rejected }

class LeaveType {
  final String name;
  final int id;

  LeaveType({required this.name, required this.id});

  @override
  String toString() => name;
}

class LeaveRequest {
  final int type; 
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final String project;
  final DateTime submittedDate;

  LeaveRequest({
    required this.type,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.project,
    required this.submittedDate,
  });
}