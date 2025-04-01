import 'package:flutter/material.dart';
import '../../chat_group/screens/group_chat_screen.dart';

class GroupListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final int currentUserId;

  const GroupListWidget({
    Key? key,
    required this.groups,
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
              children:
                  groups
                      .map((group) => _buildGroupItem(context, group))
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildGroupItem(BuildContext context, Map<String, dynamic> group) {
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
                    currentUserId: currentUserId,
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
