// lib/models/ProjectModel.dart
import 'package:html/parser.dart' as html_parser;

class ProjectModel {
  final String? title;
  final String? description;
  final String? departmentName;
  final String? status;
  final String? startDate;
  final String? endDate;

  ProjectModel({
    required this.title,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.departmentName,
  });

  /// Convert object → JSON (for saving or sending to API)
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'departmentName': departmentName,
        'status': status,
        'startDate': startDate,
        'endDate': endDate,
      };

  /// Convert JSON → object (from API or SharedPreferences)
 factory ProjectModel.fromJson(Map<String, dynamic> json) {
  String? sanitize(String? html) {
      if (html == null) return null;
      final document = html_parser.parse(html);
      return document.body?.text.trim(); // ✅ strips all HTML tags safely
    }
    return ProjectModel(
     
      title: json['name']?.toString() ?? '',
      description: sanitize(json['description']?.toString()), // ✅ safely convert any type
      startDate: json['date_start']?.toString(),
      endDate: json['date']?.toString(),
      status: json['state']?.toString()
    );
  }

  /// Optional: Nice print for debugging
  @override
  String toString() {
    return 'ProjectModel(title: $title, status: $status, dept: $departmentName)';
  }
}