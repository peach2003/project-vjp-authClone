import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class GroupMessageContent extends StatelessWidget {
  final Map<String, dynamic> message;
  final BuildContext parentContext;

  const GroupMessageContent({
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

      default:
        if (message["message"].toString().contains('cloudinary.com') ||
            message["message"].toString().contains('.jpg') ||
            message["message"].toString().contains('.jpeg') ||
            message["message"].toString().contains('.png') ||
            message["message"].toString().contains('.gif')) {
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
        }
        return Text(
          message["message"],
          style: TextStyle(fontSize: 16, color: Colors.black),
        );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(parentContext).push(
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
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  IconData _getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
