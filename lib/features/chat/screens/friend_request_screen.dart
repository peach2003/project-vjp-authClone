import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendRequestScreen extends StatefulWidget {
  final int currentUserId;
  const FriendRequestScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  List<Map<String, dynamic>> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
  }

  // 🔹 Lấy danh sách lời mời kết bạn từ server
  Future<void> fetchFriendRequests() async {
    try {
      final response = await Dio().get("http://10.0.2.2:3000/friends/pending/${widget.currentUserId}");
      setState(() {
        friendRequests = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách lời mời kết bạn: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Xử lý chấp nhận lời mời
  Future<void> acceptRequest(int friendId) async {
    try {
      await Dio().post("http://10.0.2.2:3000/friends/accept", data: {
        "fromUser": friendId,
        "toUser": widget.currentUserId,
      });

      setState(() {
        friendRequests.removeWhere((user) => user['id'] == friendId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã chấp nhận kết bạn!")),
      );
    } catch (e) {
      print("❌ Lỗi khi chấp nhận lời mời kết bạn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi chấp nhận kết bạn")),
      );
    }
  }

  // 🔹 Xử lý từ chối lời mời
  Future<void> rejectRequest(int friendId) async {
    try {
      await Dio().post("http://10.0.2.2:3000/friends/reject", data: {
        "fromUser": friendId,
        "toUser": widget.currentUserId,
      });

      setState(() {
        friendRequests.removeWhere((user) => user['id'] == friendId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã từ chối kết bạn!")),
      );
    } catch (e) {
      print("❌ Lỗi khi từ chối lời mời kết bạn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi từ chối kết bạn")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lời mời kết bạn")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : friendRequests.isEmpty
          ? Center(child: Text("Không có lời mời kết bạn"))
          : ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final user = friendRequests[index];
          return ListTile(
            title: Text(user['username']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => acceptRequest(user['id']),
                  child: Text("Chấp nhận"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => rejectRequest(user['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text("Từ chối"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
