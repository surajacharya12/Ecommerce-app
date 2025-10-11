import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

final String _baseUrl = API_URL;
const String _notificationEndpoint = '/notification';

class NotificationService {
  Future<List<NotificationModel>> fetchAllNotifications() async {
    final uri = Uri.parse('$_baseUrl$_notificationEndpoint');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> notificationsData = responseData['data'];
          return notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
            responseData['message'] ??
                'Failed to load notifications: API reported failure.',
          );
        }
      } else {
        throw Exception(
          'Failed to load notifications. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
