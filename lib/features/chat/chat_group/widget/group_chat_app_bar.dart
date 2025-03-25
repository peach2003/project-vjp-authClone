import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String groupName;
  final VoidCallback onBackPressed;

  const GroupChatAppBar({
    Key? key,
    required this.groupName,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        groupName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: onBackPressed,
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.video_call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
