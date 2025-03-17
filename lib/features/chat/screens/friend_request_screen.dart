import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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
      final response = await Dio().get(
          "http://10.0.2.2:3000/friends/pending/${widget.currentUserId}");
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
      appBar: _buildZaloAppBar(),
      backgroundColor: Color(0xFFF3F3F3), // ✅ Màu nền xám giống Zalo
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 🔄 Loading
          : friendRequests.isEmpty
          ? Center(child: Text(
        "Không có lời mời kết bạn", style: TextStyle(fontSize: 17),))
          : ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final user = friendRequests[index];
          return _buildFriendRequestItem(user);
        },
      ),
    );
  }

  // 🔥 **AppBar giống Zalo**
  AppBar _buildZaloAppBar() {
    return AppBar(
      title: Text("Lời mời kết bạn", style: TextStyle(color: Colors.white),),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // Trạng thái trắng trên Android
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

  // 🔥 **UI danh sách lời mời kết bạn giống Zalo**
  // 🔥 **UI danh sách lời mời kết bạn đẹp hơn**
  Widget _buildFriendRequestItem(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Avatar người dùng
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[300],
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 12),

          // 🔹 Thông tin người dùng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Đã gửi lời mời kết bạn",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // 🔹 Nút hành động
          Row(
            children: [
              ElevatedButton(
                onPressed: () => acceptRequest(user['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text("Chấp nhận", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => rejectRequest(user['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text("Từ chối", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}