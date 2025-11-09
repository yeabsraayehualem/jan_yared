import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jan_yared/core/constants.dart';
import 'package:jan_yared/models/attendanceModel.dart';

class AttendanceProvider extends ChangeNotifier {
  Future<List<AttendanceSummaryModel>> getAttendances({
    required int employee_id,
    required String? session_id,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/web/dataset/call_kw");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$session_id',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "attendance.report",
          "method": "search_read",
          "args": [
            [
              ["name", "=", employee_id],
            ],
          ],
          "kwargs": {
            "fields": [
              "name",
              "project_id",
              "from_date",
              "to_date",
              "total_present_days",
              "total_absent_days",
              "total_on_leave_days",
              "total_worked_hours",
            ],
          },
        },
        "id": 1,
      }),
    );

    print(response.body);
    final List<dynamic> data = jsonDecode(response.body)['result'];
    final reports = data
        .map((e) => AttendanceSummaryModel.fromJson(e))
        .toList();
    print(reports);
    return reports;
  }
}
