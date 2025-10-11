import 'package:flutter/material.dart';
import 'package:client/backend_services/chat_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String productId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? existingChatId;
  final String userId;

  const ChatScreen({
    super.key,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.userId,
    this.existingChatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<Chat>? _chatFuture;
  Chat? _currentChat;

  @override
  void initState() {
    super.initState();
    _startOrFetchChat();
  }

  void _startOrFetchChat() {
    debugPrint("🟢 Opening ChatScreen for:");
    debugPrint("productId: ${widget.productId}");
    debugPrint("customerId: ${widget.customerId}");
    debugPrint("customerName: ${widget.customerName}");
    debugPrint("customerEmail: ${widget.customerEmail}");
    debugPrint("existingChatId: ${widget.existingChatId}");

    if (widget.productId.isEmpty ||
        widget.customerId.isEmpty ||
        widget.customerName.isEmpty ||
        widget.customerEmail.isEmpty) {
      throw Exception(
        "❌ Failed to start chat: Product ID, customer ID, name, and email are required",
      );
    }

    if (widget.existingChatId != null) {
      _chatFuture = _chatService.fetchChatMessages(
        widget.existingChatId!,
        widget.userId,
      );
    } else {
      _chatFuture = _chatService.startChat(
        productId: widget.productId,
        customerId: widget.userId,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        initialMessage: '',
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final tempMessage = Message(
      sender: 'customer',
      message: messageText,
      timestamp: DateTime.now(),
    );

    _messageController.clear();
    setState(() {
      _currentChat?.messages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      if (_currentChat == null || _currentChat!.id.isEmpty) {
        final newChat = await _chatService.startChat(
          productId: widget.productId,
          customerId: widget.userId,
          customerName: widget.customerName,
          customerEmail: widget.customerEmail,
          initialMessage: messageText,
        );

        setState(() {
          _currentChat = newChat;
          _chatFuture = Future.value(newChat);
        });
      } else {
        final updatedChat = await _chatService.sendMessage(
          chatId: _currentChat!.id,
          message: messageText,
          sender: 'customer',
          userId: widget.userId,
        );

        setState(() {
          _currentChat = updatedChat;
          _chatFuture = Future.value(updatedChat);
        });
      }
    } catch (e) {
      if (_currentChat != null) {
        setState(() {
          _currentChat!.messages.remove(tempMessage);
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send message: $e")));
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Chat'),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentChat != null && _currentChat!.messages.isNotEmpty
                ? _buildMessageList(_currentChat!.messages)
                : FutureBuilder<Chat>(
                    future: _chatFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading chat: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        _currentChat = snapshot.data;
                        return _buildMessageList(_currentChat!.messages);
                      }
                      return const Center(
                        child: Text('Start a conversation below!'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.deepOrange,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCustomer = message.sender == 'customer';
        return Align(
          alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isCustomer
                  ? Colors.deepOrange.shade100
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isCustomer
                    ? const Radius.circular(12)
                    : Radius.zero,
                bottomRight: isCustomer
                    ? Radius.zero
                    : const Radius.circular(12),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: isCustomer
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isCustomer ? Colors.black87 : Colors.black,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(message.timestamp.toLocal()),
                  style: TextStyle(
                    color: isCustomer ? Colors.black54 : Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
