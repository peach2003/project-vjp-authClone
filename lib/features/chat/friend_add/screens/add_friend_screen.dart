import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_friend_bloc.dart';
import '../bloc/add_friend_event.dart';
import '../bloc/add_friend_state.dart';
import '../widget/add_friend_app_bar.dart';
import '../widget/search_bar.dart';
import '../widget/user_list.dart';

class AddFriendScreen extends StatelessWidget {
  final int currentUserId;

  const AddFriendScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddFriendBloc()..add(FetchUsers(currentUserId)),
      child: _AddFriendContent(currentUserId: currentUserId),
    );
  }
}

class _AddFriendContent extends StatelessWidget {
  final int currentUserId;

  const _AddFriendContent({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddFriendBloc, AddFriendState>(
      listener: (context, state) {
        if (state is AddFriendError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const AddFriendAppBar(),
          backgroundColor: Color(0xFFF3F3F3),
          body: Column(
            children: [
              const FriendSearchBar(),
              Expanded(child: UserList(state: state)),
            ],
          ),
        );
      },
    );
  }
}
