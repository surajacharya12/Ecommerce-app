import 'package:client/backend_services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageScreen extends StatefulWidget {
  final Chat chat; // Required chat object
  final String userId;

  const MessageScreen({super.key, required this.chat, required this.userId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Message> _messages;
  bool _loading = true;
  bool _isRefreshing = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages = widget.chat.messages;
    _loading = false;

    // Refresh messages when screen loads to get latest from server
    _refreshMessages();
  }

  Future<bool> _checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:5000/api/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _refreshMessages() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes

    setState(() {
      _isRefreshing = true;
    });

    try {
      final updatedChat = await _chatService.fetchChatMessages(
        widget.chat.id,
        widget.userId,
      );

      if (mounted) {
        setState(() {
          _messages = updatedChat.messages;
          _isRefreshing = false;
        });

        // Only scroll to bottom if we're already near the bottom
        // This prevents interrupting user's reading of older messages
        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          final threshold = maxScroll - 100; // 100px threshold

          if (currentScroll >= threshold) {
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      debugPrint('Error refreshing messages: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // Clear the input immediately for better UX
    _messageController.clear();

    // Create temporary message for optimistic UI update
    final tempMessage = Message(
      senderId: widget.userId,
      message: text,
      timestamp: DateTime.now(),
      sender: 'customer', // Customer is always sending
    );

    // Add message optimistically to UI
    setState(() {
      _messages.add(tempMessage);
    });

    // Scroll to bottom after adding message
    _scrollToBottom();

    try {
      // Send message to backend and get updated chat
      final updatedChat = await _chatService.sendMessage(
        chatId: widget.chat.id,
        message: tempMessage,
      );

      // Update messages with the server response to ensure consistency
      if (mounted) {
        setState(() {
          _messages = updatedChat.messages;
          _isSending = false;
        });

        // Scroll to bottom again to show the confirmed message
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');

      // Remove the optimistic message on error
      if (mounted) {
        setState(() {
          _messages.removeWhere(
            (msg) =>
                msg.senderId == tempMessage.senderId &&
                msg.message == tempMessage.message &&
                msg.timestamp == tempMessage.timestamp,
          );
          _isSending = false;
        });

        // Check connection and show appropriate error
        _showErrorMessage(e.toString(), text);
      }
    }
  }

  Future<void> _showErrorMessage(String error, String originalText) async {
    String errorMessage = 'Failed to send message';
    String actionLabel = 'Retry';

    // Check connection first
    final hasConnection = await _checkConnection();

    if (!hasConnection) {
      errorMessage =
          'No internet connection. Check your network and try again.';
      actionLabel = 'Retry';
    } else if (error.contains('404')) {
      errorMessage = 'Chat not found. Please refresh and try again.';
      actionLabel = 'Refresh';
    } else if (error.contains('500')) {
      errorMessage = 'Server error. Please try again later.';
      actionLabel = 'Retry';
    } else if (error.contains('timeout')) {
      errorMessage = 'Request timeout. Please check your connection.';
      actionLabel = 'Retry';
    } else {
      errorMessage = 'Failed to send message. Please try again.';
      actionLabel = 'Retry';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: () {
              if (actionLabel == 'Refresh') {
                _refreshMessages();
              } else {
                _messageController.text = originalText;
              }
            },
          ),
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == 'customer';

    // Debug print to see message data
    print('Message: ${message.message}');
    print('Sender: ${message.sender}');
    print('SenderId: ${message.senderId}');
    print('IsMe: $isMe');
    print('---');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    Colors.deepOrange.shade400,
                    Colors.deepOrange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: null, // Always use gradient for better distinction
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show sender type for debugging
            if (message.sender == 'admin')
              const Text(
                'Support',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              message.message,
              style: const TextStyle(
                color: Colors.white, // Both gradients use white text
                fontSize: 16,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.timestamp),
              style: const TextStyle(
                color:
                    Colors.white70, // Both gradients use white70 for timestamp
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${widget.chat.productName}'),
            const SizedBox(height: 8),
            Text('Status: ${widget.chat.status.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Messages: ${widget.chat.messages.length}'),
            const SizedBox(height: 8),
            Text('Started: ${_formatMessageTime(widget.chat.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Chat with Seller',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showChatInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageBubble(_messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _isSending ? Colors.grey : Colors.deepOrange,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
