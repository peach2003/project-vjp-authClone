import 'package:flutter/material.dart';

class GroupMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSendPressed;
  final VoidCallback onMicPressed;
  final VoidCallback onImagePressed;
  final VoidCallback onMorePressed;

  const GroupMessageInput({
    Key? key,
    required this.controller,
    required this.isTyping,
    required this.onSendPressed,
    required this.onMicPressed,
    required this.onImagePressed,
    required this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          if (!isTyping)
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey[700],
              ),
              onPressed: () {},
            ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Tin nhắn",
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendPressed(),
            ),
          ),
          if (!isTyping) ...[
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.grey[700]),
              onPressed: onMorePressed,
            ),
            IconButton(
              icon: Icon(Icons.mic, color: Colors.grey[700]),
              onPressed: onMicPressed,
            ),
            IconButton(
              icon: Icon(Icons.image, color: Colors.grey[700]),
              onPressed: onImagePressed,
            ),
          ] else
            FloatingActionButton(
              onPressed: onSendPressed,
              mini: true,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
