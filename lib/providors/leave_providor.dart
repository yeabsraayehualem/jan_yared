import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jan_yared/core/constants.dart';
import 'package:jan_yared/models/leaveModels.dart';
import 'package:http/http.dart' as http;

class LeaveProvidor extends ChangeNotifier {
  // Fetch all leave types (hr.leave.type)
  Future<List<LeaveType>> fetchLeaveTypes({
    required int employee_id,
    required String session_id,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/web/dataset/call_kw");

    try {
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
            "model": "hr.leave.type",
            "method": "search_read",
            "args": [], // No domain filter
            "kwargs": {
              "fields": ["name", "id"],
            },
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("HTTP Error: ${response.statusCode} - ${response.body}");
        return [];
      }

      final jsonResponse = json.decode(response.body);

      // Check for JSON-RPC error
      if (jsonResponse.containsKey('error')) {
        final error = jsonResponse['error'];
        debugPrint(
          "Odoo Error: ${error['message']} - ${error['data']['debug']}",
        );
        return [];
      }
      print(response.body);
      // Extract result
      final List<dynamic> result = jsonResponse['result'] ?? [];

      // Map to LeaveType objects
      final leaveTypes = result.map((item) {
        return LeaveType(
          id: item['id'] as int,
          name: item['name'] as String? ?? 'Unnamed Leave Type',
        );
      }).toList();

      return leaveTypes;
    } catch (e) {
      debugPrint("Exception in fetchLeaveTypes: $e");
      return [];
    }
  }

  // Optional: Submit a leave request
  Future<bool> submitLeaveRequest({
    required int employeeId,
    required String sessionId,
    required LeaveRequest request,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/web/dataset/call_kw");

    try {
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
            "model": "hr.leave",
            "method": "create",
            "args": [
              {
                "employee_id": employeeId,
                "holiday_status_id": request.type,
                "request_date_from": _formatDate(request.startDate),
                "request_date_to": _formatDate(request.endDate),
                "number_of_days": request.days,
                "name": "Leave for project: ${request.project}",
              },
            ],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Submit failed: ${response.statusCode} - ${response.body}");
        return false;
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('error')) {
        debugPrint("Odoo Error: ${jsonResponse['error']['message']}");
        return false;
      }

      final result = jsonResponse['result'];
      return result != null && result is int && result > 0;
    } catch (e) {
      debugPrint("Exception in submitLeaveRequest: $e");
      return false;
    }
  }

  // Helper to format date to Odoo's expected format (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Optional: Fetch employee's leave requests
  Future<List<Map<String, dynamic>>> fetchEmployeeLeaves({
    required int employeeId,
    required String sessionId,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/web/dataset/call_kw");

    try {
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
            "model": "hr.leave",
            "method": "search_read",
            "args": [
              [
                ["employee_id", "=", employeeId],
              ],
            ],
            "kwargs": {
              "fields": [
                "name",
                "holiday_status_id",
                "state",
                "number_of_days",
                "date_from",
                "date_to",
                "request_date_from",
                "request_date_to",
              ],
            },
          },
        }),
      );

      if (response.statusCode != 200) return [];

      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('error')) return [];

      return List<Map<String, dynamic>>.from(jsonResponse['result'] ?? []);
    } catch (e) {
      debugPrint("Error fetching leaves: $e");
      return [];
    }
  }
}
