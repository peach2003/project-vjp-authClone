import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'options_menu.dart';

class ZaloAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentUserId;

  const ZaloAppBar({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Trò chuyện", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF3E88E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/images/plus.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
          onPressed: () {
            showOptionsMenu(context, currentUserId);
          },
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
