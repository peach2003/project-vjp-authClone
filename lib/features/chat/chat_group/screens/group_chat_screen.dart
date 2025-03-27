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
      create:
          (context) =>
              GroupChatBloc()..add(FetchGroupChatHistory(groupId: groupId)),
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
  bool _isLoadingMore = false;
  bool _shouldScrollToBottom = false;
  double? _previousScrollPosition;

  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool showOptions = false;
  late GroupChatBloc _groupChatBloc;

  @override
  void initState() {
    super.initState();
    _groupChatBloc = GroupChatBloc();
    _shouldScrollToBottom = true;

    _groupChatBloc.add(FetchGroupChatHistory(groupId: widget.groupId));

    startAutoRefresh();

    _messageController.addListener(() {
      setState(() {
        isTyping = _messageController.text.trim().isNotEmpty;
      });
    });

    _scrollController.addListener(_onScroll);
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isLoadingMore && mounted) {
        _groupChatBloc.add(AutoRefreshGroup(groupId: widget.groupId));
      }
    });
  }

  void _onScroll() {
    if (!_isLoadingMore &&
        _scrollController.hasClients &&
        messages.length >= 10 &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _previousScrollPosition = _scrollController.position.pixels;
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    final currentState = _groupChatBloc.state;
    if (currentState is GroupChatLoaded) {
      final pagination = currentState.pagination;
      final nextPage = pagination['currentPage'] + 1;

      if (nextPage <= pagination['totalPages']) {
        setState(() {
          _isLoadingMore = true;
        });

        _groupChatBloc.add(
          LoadMoreGroupMessages(
            groupId: widget.groupId,
            page: nextPage,
            limit: pagination['messagesPerPage'],
          ),
        );
      }
    }
  }

  void _sendMessage() async {
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
      messages.insert(0, newMessage);
      isTyping = false;
      _shouldScrollToBottom = true;
    });

    _groupChatBloc.add(
      SendGroupMessage(
        groupId: widget.groupId,
        senderId: widget.currentUserId,
        message: messageText,
        messageType: "text",
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _groupChatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _groupChatBloc,
      child: Builder(
        builder: (context) {
          return BlocListener<GroupChatBloc, GroupChatState>(
            listener: (context, state) {
              if (state is GroupChatError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is GroupChatLoaded) {
                final wasAtBottom =
                    _scrollController.hasClients &&
                    _scrollController.position.pixels <= 50;

                setState(() {
                  messages = List<Map<String, dynamic>>.from(state.messages);
                  _isLoadingMore = false;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (state.isFirstLoad || _shouldScrollToBottom) {
                    _shouldScrollToBottom = false;
                    _scrollToBottom();
                  } else if (wasAtBottom && !_isLoadingMore) {
                    _scrollToBottom();
                  } else if (_isLoadingMore &&
                      _previousScrollPosition != null) {
                    _scrollController.jumpTo(_previousScrollPosition!);
                    _previousScrollPosition = null;
                  }
                });
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
              if (state is GroupChatLoading && messages.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          reverse: true,
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
                        if (_isLoadingMore)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
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

                          _groupChatBloc.add(
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
