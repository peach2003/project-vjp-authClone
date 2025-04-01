import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../service/api/friend_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/friend_request_bloc.dart';
import '../bloc/friend_request_event.dart';
import '../bloc/friend_request_state.dart';
import '../widget/friend_request_app_bar.dart';
import '../widget/friend_request_list.dart';

class FriendRequestScreen extends StatefulWidget {
  final int currentUserId;
  const FriendRequestScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FriendRequestBloc()
                ..add(FetchFriendRequests(widget.currentUserId)),
      child: FriendRequestContent(currentUserId: widget.currentUserId),
    );
  }
}

class FriendRequestContent extends StatelessWidget {
  final int currentUserId;

  const FriendRequestContent({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendRequestBloc, FriendRequestState>(
      listener: (context, state) {
        if (state is FriendRequestError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const FriendRequestAppBar(),
          backgroundColor: Color(0xFFF3F3F3),
          body: FriendRequestList(state: state, currentUserId: currentUserId),
        );
      },
    );
  }
}
