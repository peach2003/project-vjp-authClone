import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_chat_bloc.dart';
import '../bloc/group_chat_event.dart';
import '../bloc/group_chat_state.dart';
import '../widget/group_chat_app_bar.dart';
import '../widget/group_message_bubble.dart';
import '../widget/group_message_input.dart';

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

  void _sendMessage() {
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
      appBar: GroupChatAppBar(
        groupName: widget.groupName,
        onBackPressed: () => Navigator.pop(context),
      ),
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
                      return GroupMessageBubble(message: message, isMe: isMe);
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
          GroupMessageInput(
            controller: _messageController,
            isTyping: isTyping,
            onSendPressed: _sendMessage,
            onMicPressed: () {},
            onImagePressed: () {},
            onMorePressed: () {},
          ),
        ],
      ),
    );
  }
}
