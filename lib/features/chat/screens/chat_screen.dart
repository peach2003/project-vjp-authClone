import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // 📌 Hiển thị giờ
import '../../../service/api/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<Map<String, dynamic>>> _chatStreamController =
  StreamController<List<Map<String, dynamic>>>.broadcast();

  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false; // Trạng thái nhập tin nhắn

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
    startAutoRefresh();
    // 🔹 Lắng nghe nhập liệu để ẩn/hiện icon
    _messageController.addListener(() {
      setState(() {
        isTyping = _messageController.text.trim().isNotEmpty;
      });
    });

    // 🔥 Cuộn xuống tin nhắn mới nhất khi mở màn hình chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchChatHistory();
    });
  }

  Future<void> fetchChatHistory() async {
    List<Map<String, dynamic>> chatData = await _chatService.getChatHistory(
      widget.currentUserId,
      widget.receiverId,
    );
    if (mounted) {
      setState(() {
        messages = chatData;
        messages = List<Map<String, dynamic>>.from(chatData).map((msg) {
          // Chuyển đổi timestamp sang DateTime local trước khi lưu vào state
          msg["created_at"] = DateTime.parse(msg["created_at"]).toLocal();
          return msg;
        }).toList();
      });
      _chatStreamController.add(messages);
      _scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final newMessage = {
      "sender": widget.currentUserId,
      "receiver": widget.receiverId,
      "message": messageText,
      "message_type": "text",
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(newMessage);
    });

    _chatStreamController.add(messages);
    _scrollToBottom(force: true);

    bool success = await _chatService.sendMessage(
      widget.currentUserId,
      widget.receiverId,
      messageText,
      "text",
    );

    if (!success) {
      print("❌ Gửi tin nhắn thất bại");
    }
  }

  void _scrollToBottom({bool force = false}) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        if (force ||
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 100) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _chatStreamController.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      backgroundColor: Color(0xFFF1F1F1),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isMe = message["sender"] == widget.currentUserId;
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // 🔹 Thanh AppBar Gradient giống Zalo
  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        widget.receiverName,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        IconButton(icon: Icon(Icons.phone, color: Colors.white), onPressed: () {}),
        IconButton(icon: Icon(Icons.video_call, color: Colors.white), onPressed: () {}),
        IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  // 🔹 Tin nhắn tự mở rộng theo nội dung
  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    // ✅ Chuyển created_at từ String sang DateTime local
    DateTime messageTime = message["created_at"] is String
        ? DateTime.parse(message["created_at"]).toLocal()
        : message["created_at"];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.66,
          ),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  message["message"],
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat('HH:mm').format(messageTime), // ✅ Hiển thị giờ chính xác
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Ô nhập tin nhắn động
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          if (!isTyping) IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[700]), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Tin nhắn",
                border: InputBorder.none,
              ),
            ),
          ),
          if (!isTyping) ...[
            IconButton(icon: Icon(Icons.more_horiz, color: Colors.grey[700]), onPressed: () {}),
            IconButton(icon: Icon(Icons.mic, color: Colors.grey[700]), onPressed: () {}),
            IconButton(icon: Icon(Icons.image, color: Colors.grey[700]), onPressed: () {}),
          ] else
            FloatingActionButton(
              onPressed: sendMessage,
              mini: true,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
