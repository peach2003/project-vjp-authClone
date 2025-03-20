import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // 📌 Hiển thị giờ
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../../service/api/chat_service.dart';

class ChatScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ChatBloc()..add(
                FetchChatHistory(
                  currentUserId: currentUserId,
                  receiverId: receiverId,
                ),
              ),
      child: _ChatContent(
        currentUserId: currentUserId,
        receiverId: receiverId,
        receiverName: receiverName,
      ),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final int currentUserId;
  final int receiverId;
  final String receiverName;

  const _ChatContent({
    Key? key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatContentState createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(() {
      setState(() {
        isTyping = _messageController.text.trim().isNotEmpty;
      });
    });

    startAutoRefresh();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<ChatBloc>().add(
          AutoRefresh(
            currentUserId: widget.currentUserId,
            receiverId: widget.receiverId,
          ),
        );
      }
    });
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;

    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() {
      isTyping = false;
    });

    context.read<ChatBloc>().add(
      SendMessage(
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
        message: message,
        messageType: "text",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      backgroundColor: Color(0xFFF1F1F1),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (previous, current) {
                if (previous is ChatLoaded && current is ChatLoaded) {
                  return previous.hasNewMessages(current);
                }
                return true;
              },
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollToBottom();
                } else if (state is ChatMessageSent) {
                  context.read<ChatBloc>().add(
                    FetchChatHistory(
                      currentUserId: widget.currentUserId,
                      receiverId: widget.receiverId,
                    ),
                  );
                } else if (state is ChatError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              buildWhen: (previous, current) {
                if (previous is ChatLoaded && current is ChatLoaded) {
                  return previous.hasNewMessages(current);
                }
                return true;
              },
              builder: (context, state) {
                if (state is ChatInitial ||
                    (state is ChatLoading && state is! ChatLoaded)) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(child: Text('Chưa có tin nhắn nào'));
                  }

                  return ListView.builder(
                    key: PageStorageKey('chat_messages'),
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      bool isMe = message["sender"] == widget.currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                }

                if (state is ChatError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${state.message}'));
                }

                return Container();
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.video_call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
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
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
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
              onPressed: _sendMessage,
              mini: true,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
