import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message_content.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final BuildContext parentContext;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Chuyển created_at từ String sang DateTime local
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
              Flexible(
                child: MessageContent(
                  message: message,
                  parentContext: parentContext,
                ),
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
}
