import 'dart:convert';
import 'dart:io';
import 'package:client/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final String baseUrl = API_URL;

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
          'message': data['message'] ?? 'Failed to fetch user profile',
        };
      }
    } catch (e) {
      debugPrint('Get profile exception: $e');
      return {'success': false, 'message': 'Error: Network or server issue.'};
    }
  }

  /**
   * UPDATED: Now only handles name and password updates via JSON PUT.
   * Photo updates are handled by uploadUserPhoto.
   */
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String name,
    String? password,
    // REMOVED: String? photo,
  }) async {
    try {
      final bodyMap = {
        'name': name,
        if (password != null && password.isNotEmpty) 'password': password,
        // photo field is no longer included in the JSON body
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

  /**
   * Photo upload function remains correct and is used by ProfileSettingsPage now.
   */
  Future<Map<String, dynamic>> uploadUserPhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Targets the new dedicated photo upload endpoint
      final uri = Uri.parse('$baseUrl/users/photo-upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['id'] = userId; // User ID field

      final mimeType = lookupMimeType(imageFile.path)?.split('/');
      if (mimeType == null) throw Exception('Cannot determine MIME type');

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo', // Must match the server's expected field name
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
}
