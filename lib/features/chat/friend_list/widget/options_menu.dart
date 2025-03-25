import 'package:flutter/material.dart';
import '../../friend_add/screens/add_friend_screen.dart';
import '../../friend_request/screens/friend_request_screen.dart';
import '../../create_group/screens/create_group_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/friend_list_bloc.dart';
import '../bloc/friend_list_event.dart';

void showOptionsMenu(BuildContext context, int currentUserId) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final RelativeRect position = RelativeRect.fromLTRB(
    button.localToGlobal(Offset.zero, ancestor: overlay).dx +
        button.size.width -
        180,
    button.localToGlobal(Offset.zero, ancestor: overlay).dy + kToolbarHeight,
    20,
    0,
  );

  showMenu(
    context: context,
    position: position,
    color: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    items: [
      _buildPopupMenuItemWithImage(
        'Thêm bạn',
        'assets/images/add-user.png',
        Colors.blue,
      ),
      _buildDivider(),
      _buildPopupMenuItemWithImage(
        'Lời mời kết bạn',
        'assets/images/notificaton.png',
        Colors.orange,
      ),
      _buildDivider(),
      _buildPopupMenuItemWithImage(
        'Tạo nhóm',
        'assets/images/add_group.png',
        Colors.green,
      ),
    ],
  ).then((value) {
    if (value == null) return;

    switch (value) {
      case 'Thêm bạn':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFriendScreen(currentUserId: currentUserId),
          ),
        );
        break;
      case 'Lời mời kết bạn':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FriendRequestScreen(currentUserId: currentUserId),
          ),
        );
        break;
      case 'Tạo nhóm':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CreateGroupScreen(currentUserId: currentUserId),
          ),
        ).then((_) {
          context.read<FriendListBloc>().add(FetchGroups(currentUserId));
        });
        break;
      default:
        break;
    }
  });
}

// Tạo divider giữa các mục menu
PopupMenuItem<String> _buildDivider() {
  return PopupMenuItem<String>(
    enabled: false,
    height: 1,
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
  );
}

// Item trong Menu Popup với hình ảnh
PopupMenuItem<String> _buildPopupMenuItemWithImage(
  String title,
  String imagePath,
  Color iconColor,
) {
  return PopupMenuItem<String>(
    value: title,
    height: 46,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image.asset(
            imagePath,
            width: 18,
            height: 18,
            color: iconColor,
          ),
        ),
        SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ],
    ),
  );
}
