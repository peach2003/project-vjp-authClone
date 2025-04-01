import 'package:flutter/material.dart';

class GroupMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSendPressed;
  final VoidCallback onEllipsisPressed;
  final VoidCallback onMicPressed;
  final VoidCallback onStickerPressed;
  final VoidCallback onImagePressed;

  const GroupMessageInput({
    Key? key,
    required this.controller,
    required this.isTyping,
    required this.onSendPressed,
    required this.onEllipsisPressed,
    required this.onMicPressed,
    required this.onStickerPressed,
    required this.onImagePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onPressed: onStickerPressed,
              ),
            Expanded(
              child: TextField(
                controller: controller,
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
                onPressed: onEllipsisPressed,
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/mic.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: onMicPressed,
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/image.png',
                  width: 24,
                  height: 24,
                ),
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
      ),
    );
  }
}
