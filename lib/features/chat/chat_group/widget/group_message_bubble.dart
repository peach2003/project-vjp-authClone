import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final BuildContext parentContext;

  const GroupMessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.parentContext,
  }) : super(key: key);

  Widget _buildMessageContent() {
    final messageType = message['message_type'] as String? ?? 'text';
    final messageContent = message['message'] as String;

    switch (messageType) {
      case 'image':
        return GestureDetector(
          onTap: () {
            // Hiển thị hình ảnh full screen khi click
            showDialog(
              context: parentContext,
              builder:
                  (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          child: Image.network(
                            messageContent,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              messageContent,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
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
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
        );
      default:
        return Text(
          messageContent,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime messageTime =
        message["created_at"] is String
            ? DateTime.parse(message["created_at"]).toLocal()
            : message["created_at"];
    final senderName = message['sender_name'] as String? ?? 'Unknown';

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
              if (!isMe) ...[
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
              ],
              _buildMessageContent(),
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
}
