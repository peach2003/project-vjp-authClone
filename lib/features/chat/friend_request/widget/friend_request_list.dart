import 'package:flutter/material.dart';
import '../bloc/friend_request_state.dart';
import 'request_item.dart';

class FriendRequestList extends StatelessWidget {
  final FriendRequestState state;
  final int currentUserId;

  const FriendRequestList({
    Key? key,
    required this.state,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is FriendRequestLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is FriendRequestLoaded) {
      final requestState = state as FriendRequestLoaded;

      if (requestState.requests.isEmpty) {
        return Center(
          child: Text(
            "Không có lời mời kết bạn",
            style: TextStyle(fontSize: 17),
          ),
        );
      }

      return ListView.builder(
        itemCount: requestState.requests.length,
        itemBuilder: (context, index) {
          final user = requestState.requests[index];
          return RequestItem(user: user, currentUserId: currentUserId);
        },
      );
    }

    return Container();
  }
}
