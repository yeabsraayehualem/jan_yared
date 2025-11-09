import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jan_yared/core/constants.dart';
import 'package:jan_yared/models/projectModel.dart';

class ProjectsProvider  extends ChangeNotifier{
  Future<List<ProjectModel>> getProjects({
    required String sessionId,
    required int employeeId,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/web/dataset/call_kw");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "project.project",
          "method": "search_read",
          "args": [
            [
              [
                "assignee_ids",
                "in",
                [employeeId],
              ],
            ],
          ],
          "kwargs": {
            "fields": ["name", "date_start", "date", "description"],
          },
        },
        "id": 2,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      final List<dynamic>? records = result['result'];
      if (records == null) return [];

      return records.map((r) => ProjectModel.fromJson(r)).toList();
    } else {
      throw Exception("Failed to fetch projects: ${response.body}");
    }
  }



}
