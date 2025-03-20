import 'package:equatable/equatable.dart';

abstract class FriendListEvent extends Equatable {
  const FriendListEvent();

  @override
  List<Object> get props => [];
}

class FetchFriends extends FriendListEvent {
  final int currentUserId;

  const FetchFriends(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class FetchGroups extends FriendListEvent {
  final int currentUserId;

  const FetchGroups(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class StartAutoRefresh extends FriendListEvent {
  final int currentUserId;

  const StartAutoRefresh(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class StopAutoRefresh extends FriendListEvent {}
