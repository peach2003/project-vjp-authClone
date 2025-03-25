import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/friend_list_bloc.dart';
import '../bloc/friend_list_event.dart';
import '../bloc/friend_list_state.dart';
import '../widget/zalo_app_bar.dart';
import '../widget/search_bar.dart' as custom_widgets;
import '../widget/friend_list_widget.dart';
import '../widget/group_list_widget.dart';

class FriendListScreen extends StatefulWidget {
  final int currentUserId;

  const FriendListScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FriendListBloc()
                ..add(FetchFriends(widget.currentUserId))
                ..add(FetchGroups(widget.currentUserId))
                ..add(StartAutoRefresh(widget.currentUserId)),
      child: BlocBuilder<FriendListBloc, FriendListState>(
        builder: (context, state) {
          if (state is FriendListLoading) {
            return Scaffold(
              appBar: ZaloAppBar(currentUserId: widget.currentUserId),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is FriendListError) {
            return Scaffold(
              appBar: ZaloAppBar(currentUserId: widget.currentUserId),
              body: Center(child: Text(state.message)),
            );
          }
          if (state is FriendListLoaded) {
            return Scaffold(
              appBar: ZaloAppBar(currentUserId: widget.currentUserId),
              backgroundColor: Color(0xFFF3F3F3),
              body: Column(
                children: [
                  const custom_widgets.SearchBar(),
                  Expanded(
                    child: ListView(
                      children: [
                        FriendListWidget(
                          friends: state.friends,
                          currentUserId: widget.currentUserId,
                        ),
                        GroupListWidget(
                          groups: state.groups,
                          currentUserId: widget.currentUserId,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
