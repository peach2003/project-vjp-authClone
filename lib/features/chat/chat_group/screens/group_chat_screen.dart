import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/group_chat_bloc.dart';
import '../bloc/group_chat_event.dart';
import '../bloc/group_chat_state.dart';

class GroupChatScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupChatBloc()..add(FetchGroupMessages(groupId)),
      child: _GroupChatContent(
        currentUserId: currentUserId,
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }
}

class _GroupChatContent extends StatefulWidget {
  final int currentUserId;
  final int groupId;
  final String groupName;

  const _GroupChatContent({
    Key? key,
    required this.currentUserId,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupChatContentState createState() => _GroupChatContentState();
}

class _GroupChatContentState extends State<_GroupChatContent> {
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
        context.read<GroupChatBloc>().add(AutoRefresh(widget.groupId));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      backgroundColor: Color(0xFFF1F1F1),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<GroupChatBloc, GroupChatState>(
              listenWhen: (previous, current) {
                if (previous is GroupChatLoaded && current is GroupChatLoaded) {
                  return previous.hasNewMessages(current);
                }
                return true;
              },
              listener: (context, state) {
                if (state is GroupChatLoaded) {
                  _scrollToBottom();
                } else if (state is GroupChatMessageSent) {
                  context.read<GroupChatBloc>().add(
                    FetchGroupMessages(widget.groupId),
                  );
                } else if (state is GroupChatError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              buildWhen: (previous, current) {
                if (previous is GroupChatLoaded && current is GroupChatLoaded) {
                  return previous.hasNewMessages(current);
                }
                return true;
              },
              builder: (context, state) {
                if (state is GroupChatInitial ||
                    (state is GroupChatLoading && state is! GroupChatLoaded)) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is GroupChatLoaded) {
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

                if (state is GroupChatError) {
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
              if (!isMe) ...[
                Text(
                  message["username"] ?? "Unknown",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
              ],
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
              onSubmitted: (_) {
                final message = _messageController.text.trim();
                if (message.isNotEmpty) {
                  context.read<GroupChatBloc>().add(
                    SendGroupMessage(
                      groupId: widget.groupId,
                      senderId: widget.currentUserId,
                      message: message,
                    ),
                  );
                  _messageController.clear();
                  setState(() {
                    isTyping = false;
                  });
                }
              },
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
              onPressed: () {
                final message = _messageController.text.trim();
                if (message.isNotEmpty) {
                  context.read<GroupChatBloc>().add(
                    SendGroupMessage(
                      groupId: widget.groupId,
                      senderId: widget.currentUserId,
                      message: message,
                    ),
                  );
                  _messageController.clear();
                  setState(() {
                    isTyping = false;
                  });
                }
              },
              mini: true,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
