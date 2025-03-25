import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // 📌 Hiển thị giờ
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../service/api/chat_service.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
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
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<Map<String, dynamic>>> _chatStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Timer? _refreshTimer;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false; // Trạng thái nhập tin nhắn
  bool showOptions = false;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
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
        messages =
            List<Map<String, dynamic>>.from(chatData).map((msg) {
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
              } else if (state is ChatUploadSuccess) {
                fetchChatHistory();
              }
            },
            child: Scaffold(
              appBar: _buildCustomAppBar(),
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
          Column(
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
              _buildMessageInputSection(context),
              if (showOptions) _buildOptionsSection(context),
            ],
          ),
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
          icon: Image.asset(
            'assets/images/telephone1.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset(
            'assets/images/video.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset(
            'assets/images/list.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // 🔹 Tin nhắn tự mở rộng theo nội dung
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _buildMessageContent(message)),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat(
                    'HH:mm',
                  ).format(messageTime), // ✅ Hiển thị giờ chính xác
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    switch (message["message_type"]) {
      case "text":
        return Text(
          message["message"],
          style: TextStyle(fontSize: 16, color: Colors.black),
        );

      case "image":
        return GestureDetector(
          onTap: () => _showFullScreenImage(message["message"]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message["message"],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error_outline, color: Colors.red),
                );
              },
            ),
          ),
        );

      case "video":
        return GestureDetector(
          onTap: () => _playVideo(message["message"]),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message["thumbnail"] ?? "placeholder_image_url",
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
        );

      case "file":
        // Trích xuất tên file từ URL nếu có thể
        String fileName = "Tài liệu";
        String fileExtension = "";

        // Lấy tên file từ metadata nếu có
        if (message.containsKey("file_name") && message["file_name"] != null) {
          fileName = message["file_name"];
        } else {
          // Thử trích xuất từ URL
          final Uri uri = Uri.parse(message["message"]);
          String path = uri.path;
          fileName = path.split('/').last;

          // Nếu tên file không có đuôi, thử lấy từ các thông tin khác
          if (message.containsKey("file_extension") &&
              message["file_extension"] != null) {
            fileExtension = message["file_extension"];
            if (!fileName.endsWith(fileExtension)) {
              fileName = "$fileName$fileExtension";
            }
          }
        }

        // Xác định icon dựa vào đuôi file
        IconData fileIcon = _getFileIcon(fileName);

        return GestureDetector(
          onTap: () => _downloadFile(message["message"], fileName),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(fileIcon, color: _getFileIconColor(fileName), size: 36),
                SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "Nhấn để tải xuống",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Text(
          message["message"],
          style: TextStyle(fontSize: 16, color: Colors.black),
        );
    }
  }

  // Xác định icon cho file dựa vào đuôi file
  IconData _getFileIcon(String fileName) {
    fileName = fileName.toLowerCase();
    if (fileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Icons.slideshow;
    } else if (fileName.endsWith('.zip') ||
        fileName.endsWith('.rar') ||
        fileName.endsWith('.7z')) {
      return Icons.folder_zip;
    } else if (fileName.endsWith('.txt')) {
      return Icons.text_snippet;
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png')) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Màu sắc cho icon dựa vào đuôi file
  Color _getFileIconColor(String fileName) {
    fileName = fileName.toLowerCase();
    if (fileName.endsWith('.pdf')) {
      return Colors.red;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Colors.blue;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Colors.green;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Colors.orange;
    } else if (fileName.endsWith('.zip') ||
        fileName.endsWith('.rar') ||
        fileName.endsWith('.7z')) {
      return Colors.brown;
    } else {
      return Colors.blue;
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _playVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      // Kiểm tra xem có thể mở URL hay không
      final url = Uri.parse(fileUrl);
      debugPrint("🔽 Tải file: $fileUrl với tên: $fileName");

      if (await canLaunchUrl(url)) {
        // Mở URL bằng trình duyệt hoặc ứng dụng tương ứng
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở hoặc tải file này')),
        );
      }
    } catch (e) {
      debugPrint("❌ Error downloading file: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải file: $e')));
    }
  }

  Widget _buildMessageInputSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isTyping)
              IconButton(
                icon: Image.asset(
                  'assets/images/sticker.png',
                  width: 24,
                  height: 24,
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
                icon: Image.asset(
                  'assets/images/ellipsis.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  setState(() {
                    showOptions = !showOptions;
                    if (showOptions) {
                      FocusScope.of(context).unfocus();
                    }
                  });
                },
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/mic.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
              Builder(
                builder:
                    (context) => IconButton(
                      // icon: Icon(Icons.image, color: Colors.grey[700]),
                      icon: Image.asset(
                        'assets/images/image.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () async {
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
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'icon': Icons.location_on, 'color': Colors.red, 'label': 'Vị trí'},
      {'icon': Icons.phone_android, 'color': Colors.blue, 'label': 'Tài liệu'},
      {'icon': Icons.access_time, 'color': Colors.orange, 'label': 'Nhắc hẹn'},
      {'icon': Icons.bar_chart, 'color': Colors.green, 'label': 'Biểu đồ'},
      {
        'icon': Icons.cloud,
        'color': Colors.lightBlue,
        'label': 'Cloud của tôi',
      },
      {
        'icon': Icons.message,
        'color': Colors.purple,
        'label': 'Tin nhắn nhanh',
      },
      {'icon': Icons.live_tv, 'color': Colors.red, 'label': 'Livestream'},
      {'icon': Icons.gif, 'color': Colors.teal, 'label': 'Vẽ bậy'},
    ];

    return Container(
      height: 280,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              if (options[index]['label'] == 'Tài liệu') {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                if (result != null && mounted) {
                  context.read<ChatBloc>().add(
                    SendFile(
                      currentUserId: widget.currentUserId,
                      receiverId: widget.receiverId,
                      filePath: result.files.single.path!,
                    ),
                  );
                  setState(() {
                    showOptions = false;
                  });
                }
              } else {
                print('Selected option: ${options[index]['label']}');
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    options[index]['icon'],
                    color: options[index]['color'],
                    size: 26,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  options[index]['label'],
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
