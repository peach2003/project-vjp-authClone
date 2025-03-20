import 'package:equatable/equatable.dart';

abstract class FriendRequestEvent extends Equatable {
  const FriendRequestEvent();

  @override
  List<Object> get props => [];
}

class FetchFriendRequests extends FriendRequestEvent {
  final int currentUserId;

  const FetchFriendRequests(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class AcceptRequest extends FriendRequestEvent {
  final int currentUserId;
  final int friendId;

  const AcceptRequest({
    required this.currentUserId,
    required this.friendId,
  });

  @override
  List<Object> get props => [currentUserId, friendId];
}

class RejectRequest extends FriendRequestEvent {
  final int currentUserId;
  final int friendId;

  const RejectRequest({
    required this.currentUserId,
    required this.friendId,
  });

  @override
  List<Object> get props => [currentUserId, friendId];
}