import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AuthRepository {
  Future<Map<String, dynamic>> authenticate({
    required String login,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authenticateEndpoint}');
    
    final payload = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'db': ApiConstants.database,
        'login': login,
        'password': password,
      },
      'id': 1,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Check for error in response
        if (data.containsKey('error')) {
          throw Exception(data['error']['message'] ?? 'Authentication failed');
        }
        
        return data;
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

