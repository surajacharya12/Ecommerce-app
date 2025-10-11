import 'dart:convert';
import 'dart:io';
import 'package:client/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';

class BackendService {
  final String baseUrl = API_URL;

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Login response (${response.statusCode}): ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        final rawId = user['id'] ?? user['_id'];
        final userId = rawId?.toString();

        return {
          'success': true,
          'user': user,
          'userId': userId,
          'token': data['data']['token'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      debugPrint('Login exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? photo,
  }) async {
    try {
      final bodyMap = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        if (photo != null) 'photo': photo,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      );

      debugPrint('Register response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final user = data['data']['user'];
        final userId = (user['id'] ?? user['_id']).toString();
        return {
          'success': true,
          'message': data['message'],
          'user': user,
          'userId': userId,
          'token': data['data']['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      debugPrint('Register exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  Future<Map<String, dynamic>> uploadUserPhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/photo-upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['id'] = userId;

      final mimeType = lookupMimeType(imageFile.path)?.split('/');
      if (mimeType == null) throw Exception('Cannot determine MIME type');

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['data']['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Photo upload failed',
        };
      }
    } catch (e) {
      debugPrint('Upload photo exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  Future<Map<String, dynamic>> getUserProfile({required String userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Profile response: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'user': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch user',
        };
      }
    } catch (e) {
      debugPrint('Get profile exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String name,
    String? password,
    String? photo,
  }) async {
    try {
      final bodyMap = {
        'name': name,
        if (password != null && password.isNotEmpty) 'password': password,
        if (photo != null && photo.isNotEmpty) 'photo': photo,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      debugPrint('Update profile exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount({
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Delete failed',
        };
      }
    } catch (e) {
      debugPrint('Delete user exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }
}
