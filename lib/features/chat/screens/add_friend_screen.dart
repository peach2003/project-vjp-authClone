import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFriendScreen extends StatefulWidget {
  final int currentUserId;
  const AddFriendScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  List<Map<String, dynamic>> users = [];
  Set<int> sentRequests = {}; // Lưu trạng thái gửi lời mời kết bạn
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // 🔹 Lấy danh sách user (trừ user đang đăng nhập)
  Future<void> fetchUsers() async {
    try {
      final response = await Dio().get("http://10.0.2.2:3000/users/all/${widget.currentUserId}");
      setState(() {
        users = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách user: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Gửi lời mời kết bạn
  Future<void> sendFriendRequest(int friendId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? currentUserId = prefs.getInt("userId");

      if (currentUserId == null) {
        print("❌ Không tìm thấy userId trong SharedPreferences");
        return;
      }

      print("🔹 Đang gửi lời mời từ $currentUserId đến $friendId");

      await Dio().post("http://10.0.2.2:3000/friends/request", data: {
        "fromUser": currentUserId,
        "toUser": friendId,
      });

      setState(() {
        sentRequests.add(friendId); // Cập nhật trạng thái gửi thành công
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã gửi lời mời kết bạn!")),
      );
    } catch (e) {
      print("❌ Lỗi khi gửi lời mời kết bạn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi lời mời kết bạn")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildZaloAppBar(),
      backgroundColor: Color(0xFFF3F3F3), // ✅ Màu nền xám giống Zalo
      body: Column(
        children: [
          _buildSearchBar(), // 🔍 Thanh tìm kiếm
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // 🔄 Loading
                : users.isEmpty
                ? Center(child: Text("Không có người dùng nào để kết bạn", style: TextStyle(fontSize: 16),))
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserItem(user);
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
      title: Text("Thêm bạn mới", style: TextStyle(color: Colors.white),),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light, // Trạng thái trắng trên Android
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007AFF), // Màu xanh đậm Zalo
              Color(0xFF4A90E2), // Màu xanh nhạt Zalo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
    );
  }

  // 🔍 **Thanh tìm kiếm giống Zalo**
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm người dùng...",
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

  // 🔥 **UI danh sách người dùng giống Zalo**
  Widget _buildUserItem(Map<String, dynamic> user) {
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
          user['username'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Người dùng mới"), // ✅ Hiển thị mô tả
        trailing: sentRequests.contains(user['id'])
            ? ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text("Đã gửi", style: TextStyle(color: Colors.white)),
        )
            : ElevatedButton(
          onPressed: () => sendFriendRequest(user['id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text("Kết bạn", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
