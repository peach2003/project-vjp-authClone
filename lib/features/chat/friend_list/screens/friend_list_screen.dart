import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../service/api/friend_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/friend_list_bloc.dart';
import '../bloc/friend_list_event.dart';
import '../bloc/friend_list_state.dart';
import '../../friend_add/screens/add_friend_screen.dart';
import '../../chat_private/screens/chat_screen.dart';
import '../../create_group/screens/create_group_screen.dart';
import '../../friend_request/screens/friend_request_screen.dart';
import '../../chat_group/screens/group_chat_screen.dart';

class FriendListScreen extends StatefulWidget {
  final int currentUserId;

  const FriendListScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FriendListBloc()
                ..add(FetchFriends(widget.currentUserId))
                ..add(FetchGroups(widget.currentUserId))
                ..add(StartAutoRefresh(widget.currentUserId)),
      child: BlocBuilder<FriendListBloc, FriendListState>(
        builder: (context, state) {
          if (state is FriendListLoading) {
            return Scaffold(
              appBar: _buildZaloAppBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is FriendListError) {
            return Scaffold(
              appBar: _buildZaloAppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          if (state is FriendListLoaded) {
            return Scaffold(
              appBar: _buildZaloAppBar(),
              backgroundColor: Color(0xFFF3F3F3),
              body: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: ListView(
                      children: [
                        // _buildCreateGroupButton(),
                        _buildFriendList(state.friends),
                        _buildGroupList(state.groups),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  // 🔥 **AppBar giống Zalo**
  AppBar _buildZaloAppBar() {
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
            _showOptionsMenu(context);
          },
        ),
        SizedBox(width: 10),
      ],
    );
  }

  // 🔥 **Menu tùy chọn dưới icon**
  void _showOptionsMenu(BuildContext context) {
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
              builder:
                  (context) =>
                      AddFriendScreen(currentUserId: widget.currentUserId),
            ),
          );
          break;
        case 'Lời mời kết bạn':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FriendRequestScreen(currentUserId: widget.currentUserId),
            ),
          );
          break;
        case 'Tạo nhóm':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CreateGroupScreen(currentUserId: widget.currentUserId),
            ),
          ).then((_) {
            context.read<FriendListBloc>().add(
              FetchGroups(widget.currentUserId),
            );
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

  // 🔥 **Item trong Menu Popup với hình ảnh**
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

  // 🔍 **Thanh tìm kiếm giống Zalo**
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔥 **Danh sách bạn bè**
  Widget _buildFriendList(List<Map<String, dynamic>> friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Bạn bè",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        friends.isEmpty
            ? Center(
              child: Text("Chưa có bạn bè", style: TextStyle(fontSize: 17)),
            )
            : Column(
              children:
                  friends.map((friend) {
                    bool isOnline = friend['online'] == 1;
                    return _buildFriendItem(friend, isOnline);
                  }).toList(),
            ),
      ],
    );
  }

  // 🔥 **Danh sách nhóm**
  Widget _buildGroupList(List<Map<String, dynamic>> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Nhóm",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        groups.isEmpty
            ? Center(
              child: Text(
                "Bạn chưa tham gia nhóm nào",
                style: TextStyle(fontSize: 17),
              ),
            )
            : Column(
              children: groups.map((group) => _buildGroupItem(group)).toList(),
            ),
      ],
    );
  }

  /*// 🔥 **Nút tạo nhóm**
  Widget _buildCreateGroupButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CreateGroupScreen(currentUserId: widget.currentUserId),
            ),
          ).then((_) {
            context.read<FriendListBloc>().add(
              FetchGroups(widget.currentUserId),
            );
          });
        },
        icon: Icon(Icons.group_add, color: Colors.white),
        label: Text("Tạo nhóm mới", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }*/

  // 🔥 **UI danh sách bạn bè giống Zalo**
  Widget _buildFriendItem(Map<String, dynamic> friend, bool isOnline) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        friend['username'],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isOnline ? "🟢 Đang hoạt động" : "⚪️ Ngoại tuyến",
        style: TextStyle(
          color: isOnline ? Colors.green[500] : Colors.grey[700],
          fontSize: 15,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.chat, color: Colors.blueAccent),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatScreen(
                    currentUserId: widget.currentUserId,
                    receiverId: friend['id'],
                    receiverName: friend['username'],
                  ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 **UI danh sách nhóm**
  Widget _buildGroupItem(Map<String, dynamic> group) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.group, color: Colors.white),
      ),
      title: Text(group['name'], style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: IconButton(
        icon: Icon(Icons.chat, color: Colors.blueAccent),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GroupChatScreen(
                    currentUserId: widget.currentUserId,
                    groupId: group['id'],
                    groupName: group['name'],
                  ),
            ),
          );
        },
      ),
    );
  }
}
