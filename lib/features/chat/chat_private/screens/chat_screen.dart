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

  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false; // Trạng thái nhập tin nhắn
  bool showOptions = false;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();

    // Khởi tạo và gửi event lấy lịch sử chat
    _chatBloc.add(
      FetchChatHistory(
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
      ),
    );

    startAutoRefresh();

    // Lắng nghe nhập liệu để ẩn/hiện icon
    _messageController.addListener(() {
      setState(() {
        isTyping = _messageController.text.trim().isNotEmpty;
      });
    });

    // Cuộn xuống tin nhắn mới nhất khi mở màn hình chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });
  }

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Sử dụng AutoRefresh event từ bloc
      _chatBloc.add(
        AutoRefresh(
          currentUserId: widget.currentUserId,
          receiverId: widget.receiverId,
        ),
      );
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Thêm tin nhắn tạm thời vào UI để hiển thị ngay
    final newMessage = {
      "sender": widget.currentUserId,
      "receiver": widget.receiverId,
      "message": messageText,
      "message_type": "text",
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(newMessage);
      isTyping = false;
    });

    _scrollToBottom(force: true);

    // Gửi tin nhắn thông qua bloc
    _chatBloc.add(
      SendMessage(
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
        message: messageText,
        messageType: "text",
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
          return BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is ChatLoaded) {
                setState(() {
                  messages =
                      List<Map<String, dynamic>>.from(state.messages).map((
                        msg,
                      ) {
                        // Chuyển đổi timestamp sang DateTime local
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
              return Column(
            children: [
              Expanded(
                    child:
                        state is ChatLoading && messages.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                                bool isMe =
                                    message["sender"] == widget.currentUserId;
                                return MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  parentContext: context,
                                );
                              },
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
                        // Tắt options grid nếu đang mở
                        setState(() {
                          showOptions = false;
                        });

                        // Dispatch event một lần duy nhất
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
}
