// lib/services/odoo_api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jan_yared/models/userModel.dart';
import 'package:jan_yared/core/constants.dart';
import 'package:jan_yared/providors/auth_providor.dart';
import 'package:provider/provider.dart';

class OdooAPIService {
  final String baseUrl;
  OdooAPIService(this.baseUrl);
  
  Future<void> login(
    BuildContext context, // ← NOW RECOGNIZED!
    String db,
    String username,
    String password,
  ) async {
    // 1. AUTHENTICATE
    final authUrl = Uri.parse("$baseUrl/web/session/authenticate");
    final authResponse = await http.post(
      authUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "jsonrpc": "2.0",
        "params": {"db": db, "login": username, "password": password},
      }),
    );

    if (authResponse.statusCode != 200) throw Exception("Login failed");

    final result = jsonDecode(authResponse.body)['result'];
    if (result?['uid'] == false) throw Exception("Wrong credentials");

    // 2. EXTRACT SESSION ID
    final sessionId = authResponse.headers['set-cookie']!
        .split('session_id=')[1]
        .split(';')[0];

    // 3. FETCH USER
    final user = await _fetchUser(sessionId, result['uid']);

    // 4. SAVE & AUTO-NAVIGATE
    await context.read<AuthProvider>().save(user, sessionId);
  }

  Future<UserModel> _fetchUser(String sessionId, int uid) async {
    final url = Uri.parse("$baseUrl/web/dataset/call_kw");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "params": {
          "model": "res.users",
          "method": "search_read",
          "args": [
            [
              ["id", "=", uid],
            ],
          ],
          "kwargs": {
            "fields": ["name", "login", "phone", "employee_id"],
          },
        },
      }),
    );

    final data = (jsonDecode(response.body)['result'] as List).first;
    print(data);
    return UserModel(
      fullName: data['name'] ?? 'Employee',
      email: data['login'] ?? '',
      phone: data['phone']?.toString() ?? '',
      employeeId: (data['employee_id'] as List)[0] as int,
    );
  }
}
