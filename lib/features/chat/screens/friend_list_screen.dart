import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'add_friend_screen.dart';
import 'chat_screen.dart';
import 'friend_request_screen.dart';

class FriendListScreen extends StatefulWidget {
  final int currentUserId;

  const FriendListScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends(); // Gọi API khi mở màn hình
  }

  // 🔹 Hàm fetch danh sách bạn bè từ API
  Future<void> fetchFriends() async {
    try {
      print("🔄 Đang lấy danh sách bạn bè...");
      final response = await Dio().get(
        "http://10.0.2.2:3000/friends/list/${widget.currentUserId}",
      );
      setState(() {
        friends = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
      print("✅ Danh sách bạn bè đã cập nhật!");
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách bạn bè: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildZaloAppBar(), // ✅ AppBar giống Zalo
      backgroundColor: Color(0xFFF3F3F3), // ✅ Màu nền xám giống Zalo
      body: Column(
        children: [
          _buildSearchBar(), // 🔍 Thanh tìm kiếm
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // 🔄 Loading
                : friends.isEmpty
                ? Center(child: Text("Chưa có bạn bè", style: TextStyle(fontSize: 17),)) // ❌ Nếu không có bạn bè
                : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return _buildFriendItem(friend); // 🔥 UI giống Zalo
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 **AppBar giống Zalo**
  AppBar _buildZaloAppBar() {
    return AppBar(
      title: Text("Danh sách bạn bè", style: TextStyle(color: Colors.white),),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light, // Trạng thái trắng trên Android
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007AFF), // Màu xanh đậm Zalo
              Color(0xFF3E88E1), // Màu xanh nhạt Zalo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person_add, color: Colors.white,),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFriendScreen(currentUserId: widget.currentUserId),
              ),
            );
            fetchFriends(); // 🔥 Reload danh sách bạn bè sau khi quay lại
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white,),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendRequestScreen(
                  currentUserId: widget.currentUserId,
                ),
              ),
            );
            fetchFriends(); // 🔥 Reload danh sách bạn bè ngay sau khi quay lại
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
          hintText: "Tìm kiếm bạn bè...",
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

  // 🔥 **UI danh sách bạn bè giống Zalo**
  Widget _buildFriendItem(Map<String, dynamic> friend) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[300],
          child: Icon(Icons.person, color: Colors.white),// 🖼 Ảnh avatar mặc định
        ),
        title: Text(
          friend['username'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Online", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),), // ✅ Giả lập trạng thái online
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  currentUserId: widget.currentUserId,
                  receiverId: friend['id'],
                  receiverName: friend['username'],
                ),
              ),
            );
          },
          child: Text("Nhắn tin", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
