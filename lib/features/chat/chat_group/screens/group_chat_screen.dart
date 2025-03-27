import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/group_chat_bloc.dart';
import '../bloc/group_chat_event.dart';
import '../bloc/group_chat_state.dart';
import '../widget/group_chat_app_bar.dart';
import '../widget/group_message_bubble.dart';
import '../widget/group_message_input.dart';
import '../widget/group_options_grid.dart';

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
  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool showOptions = false;
  late GroupChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = GroupChatBloc();

    _chatBloc.add(FetchGroupMessages(widget.groupId));

    startAutoRefresh();

    _messageController.addListener(() {
      setState(() {
        isTyping = _messageController.text.trim().isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _chatBloc.add(AutoRefresh(widget.groupId));
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final newMessage = {
      "sender": widget.currentUserId,
      "message": messageText,
      "message_type": "text",
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(newMessage);
      isTyping = false;
    });

    _scrollToBottom(force: true);

    _chatBloc.add(
      SendGroupMessage(
        groupId: widget.groupId,
        senderId: widget.currentUserId,
        message: messageText,
      ),
    );
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
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Builder(
        builder: (context) {
          return BlocListener<GroupChatBloc, GroupChatState>(
            listener: (context, state) {
              if (state is GroupChatError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is GroupChatLoaded) {
                setState(() {
                  messages =
                      List<Map<String, dynamic>>.from(state.messages).map((
                        msg,
                      ) {
                        if (msg["created_at"] is String) {
                          msg["created_at"] =
                              DateTime.parse(msg["created_at"]).toLocal();
                        }
                        return msg;
                      }).toList();
                });
                _scrollToBottom();
              }
            },
            child: Scaffold(
              appBar: GroupChatAppBar(
                groupName: widget.groupName,
                onBackPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Color(0xFFF1F1F1),
              body: _buildBody(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (showOptions) {
          setState(() {
            showOptions = false;
          });
        }
      },
      child: Stack(
        children: [
          BlocBuilder<GroupChatBloc, GroupChatState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child:
                        state is GroupChatLoading && messages.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                bool isMe =
                                    message["sender"] == widget.currentUserId;
                                return GroupMessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  parentContext: context,
                                );
                              },
                            ),
                  ),
                  GroupMessageInput(
                    controller: _messageController,
                    isTyping: isTyping,
                    onSendPressed: _sendMessage,
                    onEllipsisPressed: () {
                      setState(() {
                        showOptions = !showOptions;
                        if (showOptions) {
                          FocusScope.of(context).unfocus();
                        }
                      });
                    },
                    onMicPressed: () {},
                    onStickerPressed: () {},
                    onImagePressed: () async {
                      final ImagePicker picker = ImagePicker();
                      try {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (image != null && mounted) {
                          setState(() {
                            showOptions = false;
                          });

                          _chatBloc.add(
                            SendGroupImageOrVideo(
                              groupId: widget.groupId,
                              senderId: widget.currentUserId,
                              filePath: image.path,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
                          );
                        }
                      }
                    },
                  ),
                  if (showOptions)
                    GroupOptionsGrid(
                      currentUserId: widget.currentUserId,
                      groupId: widget.groupId,
                      setShowOptions: (value) {
                        setState(() {
                          showOptions = value;
                        });
                      },
                    ),
                ],
              );
            },
          ),
          BlocBuilder<GroupChatBloc, GroupChatState>(
            builder: (context, state) {
              if (state is GroupChatUploadLoading) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang gửi tệp...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
