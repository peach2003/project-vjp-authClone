import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../service/api/chat_service.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widget/custom_app_bar.dart';
import '../widget/message_bubble.dart';
import '../widget/message_input.dart';
import '../widget/options_grid.dart';
import 'video_player_screen.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _shouldScrollToBottom = false;
  double? _previousScrollPosition;

  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool showOptions = false;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
    _shouldScrollToBottom = true;

    _chatBloc.add(
      FetchChatHistory(
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
      ),
    );

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
        _chatBloc.add(
          AutoRefresh(
            currentUserId: widget.currentUserId,
            receiverId: widget.receiverId,
          ),
        );
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
    final currentState = _chatBloc.state;
    if (currentState is ChatLoaded) {
      final pagination = currentState.pagination;
      final nextPage = pagination['currentPage'] + 1;

      if (nextPage <= pagination['totalPages']) {
        setState(() {
          _isLoadingMore = true;
        });

        _chatBloc.add(
          LoadMoreMessages(
            currentUserId: widget.currentUserId,
            receiverId: widget.receiverId,
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
      "receiver": widget.receiverId,
      "message": messageText,
      "message_type": "text",
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.insert(0, newMessage);
      isTyping = false;
      _shouldScrollToBottom = true;
    });

    _chatBloc.add(
      SendMessage(
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
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
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Builder(
        builder: (context) {
          return BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is ChatLoaded) {
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
              appBar: CustomAppBar(
                receiverName: widget.receiverName,
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
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoading && messages.isEmpty) {
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

                            bool showDate = false;
                            String? dateString;

                            if (message["created_at"] != null) {
                              final DateTime messageDate =
                                  message["created_at"] is DateTime
                                      ? message["created_at"]
                                      : DateTime.parse(message["created_at"]);

                              if (index == messages.length - 1) {
                                showDate = true;
                                dateString = DateFormat(
                                  'dd/MM/yyyy',
                                ).format(messageDate);
                              } else {
                                final nextMessage = messages[index + 1];
                                final DateTime nextDate =
                                    nextMessage["created_at"] is DateTime
                                        ? nextMessage["created_at"]
                                        : DateTime.parse(
                                          nextMessage["created_at"],
                                        );

                                if (!isSameDay(messageDate, nextDate)) {
                                  showDate = true;
                                  dateString = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(messageDate);
                                }
                              }
                            }

                            return Column(
                              children: [
                                if (showDate)
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      dateString!,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  parentContext: context,
                                ),
                              ],
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
                  MessageInput(
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

                          context.read<ChatBloc>().add(
                            SendImageOrVideo(
                              currentUserId: widget.currentUserId,
                              receiverId: widget.receiverId,
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
                    OptionsGrid(
                      currentUserId: widget.currentUserId,
                      receiverId: widget.receiverId,
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
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatUploadLoading) {
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
