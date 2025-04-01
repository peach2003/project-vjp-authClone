import 'package:flutter/material.dart';
import '../bloc/add_friend_state.dart';
import 'user_item.dart';

class UserList extends StatelessWidget {
  final AddFriendState state;

  const UserList({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is AddFriendLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is UsersLoaded) {
      final usersState = state as UsersLoaded;

      if (usersState.users.isEmpty) {
        return Center(
          child: Text(
            "Không có người dùng nào để kết bạn",
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        itemCount: usersState.users.length,
        itemBuilder: (context, index) {
          final user = usersState.users[index];
          return UserItem(user: user, sentRequests: usersState.sentRequests);
        },
      );
    }

    return Container();
  }
}
