import 'package:flutter/material.dart';
import '../../chat_private/screens/chat_screen.dart';

class FriendListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final int currentUserId;

  const FriendListWidget({
    Key? key,
    required this.friends,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    return _buildFriendItem(context, friend, isOnline);
                  }).toList(),
            ),
      ],
    );
  }

  Widget _buildFriendItem(
    BuildContext context,
    Map<String, dynamic> friend,
    bool isOnline,
  ) {
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
                    currentUserId: currentUserId,
                    receiverId: friend['id'],
                    receiverName: friend['username'],
                  ),
            ),
          );
        },
      ),
    );
  }
}
