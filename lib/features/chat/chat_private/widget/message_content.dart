import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageContent extends StatelessWidget {
  final Map<String, dynamic> message;
  final BuildContext parentContext;

  const MessageContent({
    Key? key,
    required this.message,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      parentContext,
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
    Navigator.pushNamed(parentContext, '/video_player', arguments: videoUrl);
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
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Không thể mở hoặc tải file này')),
        );
      }
    } catch (e) {
      debugPrint("❌ Error downloading file: $e");
      ScaffoldMessenger.of(
        parentContext,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải file: $e')));
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
}
