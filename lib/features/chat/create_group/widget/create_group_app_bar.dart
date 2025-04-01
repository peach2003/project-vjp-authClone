import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateGroupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateGroupAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
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
        "Tạo nhóm mới",
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
    );
  }
}
