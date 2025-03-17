import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // 📌 Thêm để hiển thị giờ
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

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
    startAutoRefresh();
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
    _scrollToBottom(force: true); // 🔥 Luôn cuộn xuống khi gửi tin nhắn

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
        // ✅ Chỉ cuộn nếu người dùng không kéo xem tin nhắn cũ
        if (force || _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    _chatStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, // Trạng thái trắng trên Android
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF007AFF), // Màu xanh đậm Zalo
                Color(0xFF4A90E2), // Màu xanh nhạt Zalo
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.receiverName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: Colors.white),
            onPressed: () {
              // Xử lý gọi điện
            },
          ),
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              // Xử lý gọi video
            },
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Mở menu thêm
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 226, 230, 241),
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

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth( // 🔥 Giúp tin nhắn mở rộng theo nội dung
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.66, // ✅ Giới hạn 2/3 màn hình
          ),
          decoration: BoxDecoration(
            color: isMe ? Color.fromARGB(255, 217, 233, 253) : Colors.white,
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
            mainAxisSize: MainAxisSize.min, // 🔥 Giúp tin nhắn co giãn tối ưu
            children: [
              Flexible(
                child: Text(
                  message["message"],
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  message["created_at"].substring(11, 16),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(onPressed: sendMessage, child: Icon(Icons.send)),
        ],
      ),
    );
  }
}
