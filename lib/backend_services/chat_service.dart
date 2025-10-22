import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

// Message Model
class Message {
  final String senderId;
  final String message;
  final DateTime timestamp;
  final String? adminId;
  final String sender; // "customer" or "admin"

  Message({
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.adminId,
    required this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId:
          json['userId'] ?? json['senderId'] ?? '', // For customer messages
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      adminId: json['adminId'] as String?,
      sender: json['sender'] as String, // "customer" or "admin"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender': sender, // Use the actual sender value
      'userId': senderId, // Backend expects userId field
      'timestamp': timestamp.toIso8601String(),
      if (adminId != null) 'adminId': adminId,
    };
  }
}

// Chat Model
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
          .map((msg) => Message.fromJson(msg))
          .toList(),
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );
  }
}

// Chat Service
class ChatService {
  final String _baseUrl = API_URL;

  // Start or fetch a chat
  Future<Chat> startChat({
    required String productId,
    required String customerId,
    required String customerName,
    required String customerEmail,
    String? initialMessage,
  }) async {
    final url = Uri.parse('$_baseUrl/chats/start');
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
      return Chat.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to start chat: ${errorBody['message']}');
    }
  }

  // Fetch chat messages by chatId
  Future<Chat> fetchChatMessages(String chatId, String customerId) async {
    final url = Uri.parse(
      '$_baseUrl/chats/$chatId?userId=$customerId&userType=customer',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to fetch chat messages: ${errorBody['message']}');
    }
  }

  // Fetch all chats for a customer
  Future<List<Chat>> fetchChatsByCustomer(String customerId) async {
    final url = Uri.parse('$_baseUrl/chats/customer/$customerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['data'] as List)
          .map((chatJson) => Chat.fromJson(chatJson))
          .toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to fetch chats: ${errorBody['message']}');
    }
  }

  // Send a message
  Future<Chat> sendMessage({
    required String chatId,
    required Message message,
  }) async {
    final url = Uri.parse('$_baseUrl/chats/$chatId/message');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to send message: ${errorBody['message']}');
    }
  }

  // Fetch chat by id (helper)
  Future<Chat> getChatById(String chatId) async {
    final url = Uri.parse('$_baseUrl/chats/$chatId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Chat.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to fetch chat by id: ${errorBody['message']}');
    }
  }
}
