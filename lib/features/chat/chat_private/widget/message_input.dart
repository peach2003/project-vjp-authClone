import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSendPressed;
  final VoidCallback onEllipsisPressed;
  final VoidCallback onMicPressed;
  final VoidCallback onStickerPressed;
  final VoidCallback onImagePressed;

  const MessageInput({
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
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
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
            if (!widget.isTyping)
              IconButton(
                icon: Image.asset(
                  'assets/images/sticker.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: widget.onStickerPressed,
              ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: "Tin nhắn",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (!widget.isTyping) ...[
              IconButton(
                icon: Image.asset(
                  'assets/images/ellipsis.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: widget.onEllipsisPressed,
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/mic.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: widget.onMicPressed,
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/image.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: widget.onImagePressed,
              ),
            ] else
              FloatingActionButton(
                onPressed: widget.onSendPressed,
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
