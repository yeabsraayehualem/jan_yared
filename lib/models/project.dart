enum ProjectStatus { active, completed }

enum ProjectCategory { construction, architecture, engineering }

class Project {
  final String title;
  final ProjectStatus status;
  final ProjectCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final int progress;

  Project({
    required this.title,
    required this.status,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });
}

