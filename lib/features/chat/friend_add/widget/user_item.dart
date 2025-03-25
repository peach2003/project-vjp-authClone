import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_friend_bloc.dart';
import '../bloc/add_friend_event.dart';

class UserItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final Set<int> sentRequests;

  const UserItem({Key? key, required this.user, required this.sentRequests})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user['username'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Người dùng mới"),
        trailing:
            sentRequests.contains(user['id'])
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
                  onPressed: () {
                    context.read<AddFriendBloc>().add(
                      SendFriendRequest(user['id']),
                    );
                  },
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
