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
        groupName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: onBackPressed,
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/images/telephone1.png',
            width: 20,
            height: 20,
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
}
