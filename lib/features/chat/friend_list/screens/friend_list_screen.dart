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
      create: (context) => FriendListBloc()
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
                        _buildCreateGroupButton(),
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
          icon: Icon(Icons.person_add, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddFriendScreen(currentUserId: widget.currentUserId),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => FriendRequestScreen(
                      currentUserId: widget.currentUserId,
                    ),
              ),
            );
          },
        ),
      ],
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

  // 🔥 **Nút tạo nhóm**
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
          ).then((_) {context.read<FriendListBloc>().add(FetchGroups(widget.currentUserId));});
        },
        icon: Icon(Icons.group_add, color: Colors.white),
        label: Text("Tạo nhóm mới", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

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
