import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
      appBar: AppBar(
        title: Text("Danh sách bạn bè"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddFriendScreen(currentUserId: widget.currentUserId),
                ),
              );
              fetchFriends(); // 🔥 Reload danh sách bạn bè sau khi quay lại
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
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
              fetchFriends(); // 🔥 Reload danh sách bạn bè ngay sau khi quay lại
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator()) // 🔄 Loading
              : friends.isEmpty
              ? Center(child: Text("Chưa có bạn bè")) // ❌ Nếu không có bạn bè
              : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    title: Text(friend['username']),
                    trailing: IconButton(
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
                      icon: Icon(Icons.chat),
                    ),
                  );
                },
              ),
    );
  }
}
