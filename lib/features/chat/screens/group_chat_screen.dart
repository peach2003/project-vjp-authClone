import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final int currentUserId;
  final int groupId;
  final String groupName;

  const GroupChatScreen({
    Key? key,
    required this.currentUserId,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
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

  // 🔹 Tự động refresh tin nhắn mỗi 2 giây
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchChatHistory();
    });
  }

  // 🔹 Lấy lịch sử tin nhắn nhóm
  Future<void> fetchChatHistory() async {
    try {
      final response = await Dio().get(
        "http://10.0.2.2:3000/group/messages/${widget.groupId}",
      );

      if (mounted) {
        setState(() {
          messages =
              List<Map<String, dynamic>>.from(response.data).map((msg) {
                // Chuyển đổi timestamp sang DateTime local trước khi lưu vào state
                msg["created_at"] = DateTime.parse(msg["created_at"]).toLocal();
                return msg;
              }).toList();
        });
        _chatStreamController.add(messages);
        _scrollToBottom();
      }
    } catch (e) {
      print("❌ Lỗi khi lấy tin nhắn nhóm: $e");
    }
  }

  // 🔹 Gửi tin nhắn nhóm
  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final newMessage = {
      "sender": widget.currentUserId,
      "message": messageText,
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(newMessage);
    });

    _chatStreamController.add(messages);
    _scrollToBottom(force: true);

    try {
      await Dio().post(
        "http://10.0.2.2:3000/group/send-message",
        data: {
          "groupId": widget.groupId,
          "sender": widget.currentUserId,
          "message": messageText,
        },
      );
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn: $e");
    }
  }

  // 🔹 Cuộn xuống tin nhắn mới nhất
  void _scrollToBottom({bool force = false}) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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

  // 🔹 AppBar giống Zalo
  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        widget.groupName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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

  // 🔹 Hiển thị tin nhắn
  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    // ✅ Chuyển created_at từ String sang DateTime local
    DateTime messageTime =
        message["created_at"] is String
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
            children: [
              Text(
                message["message"],
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat('HH:mm').format(messageTime),
                  // ✅ Hiển thị giờ chính xác
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Ô nhập tin nhắn
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          if (!isTyping)
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey[700],
              ),
              onPressed: () {},
            ),
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
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.grey[700]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.mic, color: Colors.grey[700]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.image, color: Colors.grey[700]),
              onPressed: () {},
            ),
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
