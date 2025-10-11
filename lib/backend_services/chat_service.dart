// client/backend_services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart'; // Make sure this path is correct

class Message {
  final String sender;
  final String message;
  final DateTime timestamp;
  final String? adminId; // Optional for admin messages

  Message({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.adminId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      adminId: json['adminId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'adminId': adminId,
    };
  }
}

class Chat {
  final String id;
  final String productId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String productName;
  final String status;
  final List<Message> messages;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivity;

  Chat({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.productName,
    required this.status,
    required this.messages,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivity,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] as String,
      productId: json['productId'] is Map
          ? json['productId']['_id'] as String
          : json['productId'] as String,
      customerId: json['customerId'] is Map
          ? json['customerId']['_id'] as String
          : json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      productName: json['productName'] as String,
      status: json['status'] as String,
      messages: (json['messages'] as List)
          .map((msgJson) => Message.fromJson(msgJson as Map<String, dynamic>))
          .toList(),
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );
  }
}

class ChatService {
  final String _baseUrl =
      API_URL; // Assuming API_URL is defined in config/api.dart

  Future<Chat> startChat({
    required String productId,
    required String customerId,
    required String customerName,
    required String customerEmail,
    String? initialMessage,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/chats/start',
    ); // Corrected endpoint based on backend setup
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "productId": productId,
        "customerId": customerId,
        "customerName": customerName,
        "customerEmail": customerEmail,
        if (initialMessage != null && initialMessage.isNotEmpty)
          "initialMessage": initialMessage,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data'] as Map<String, dynamic>);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to start chat: ${errorBody['message']}');
    }
  }

  Future<Chat> fetchChatMessages(String chatId, String customerId) async {
    // Assuming userId and userType are needed by the backend to mark messages as read
    final url = Uri.parse(
      '$_baseUrl/chats/$chatId?userId=$customerId&userType=customer',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data'] as Map<String, dynamic>);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to fetch chat messages: ${errorBody['message']}');
    }
  }

  Future<Chat> sendMessage({
    required String chatId,
    required String message,
    required String sender, // 'customer' or 'admin'
    required String userId, // customerId or adminId
  }) async {
    final url = Uri.parse('$_baseUrl/chats/$chatId/message');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "message": message,
        "sender": sender,
        "userId": userId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data'] as Map<String, dynamic>);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to send message: ${errorBody['message']}');
    }
  }
}
