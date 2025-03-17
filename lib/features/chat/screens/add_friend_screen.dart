import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
      appBar: AppBar(title: Text("Thêm bạn mới")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? Center(child: Text("Không có người dùng nào để kết bạn"))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['username']),
            trailing: sentRequests.contains(user['id'])
                ? ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text("Đã gửi"),
            )
                : ElevatedButton(
              onPressed: () => sendFriendRequest(user['id']),
              child: Text("Kết bạn"),
            ),
          );
        },
      ),
    );
  }
}
