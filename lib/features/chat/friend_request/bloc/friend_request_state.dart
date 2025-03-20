import 'package:equatable/equatable.dart';

abstract class FriendRequestState extends Equatable {
  const FriendRequestState();

  @override
  List<Object> get props => [];
}

class FriendRequestInitial extends FriendRequestState {}

class FriendRequestLoading extends FriendRequestState {}

class FriendRequestLoaded extends FriendRequestState {
  final List<Map<String, dynamic>> requests;

  const FriendRequestLoaded({required this.requests});

  @override
  List<Object> get props => [requests];
}

class FriendRequestAccepted extends FriendRequestState {
  final int friendId;

  const FriendRequestAccepted({required this.friendId});

  @override
  List<Object> get props => [friendId];
}

class FriendRequestRejected extends FriendRequestState {
  final int friendId;

  const FriendRequestRejected({required this.friendId});

  @override
  List<Object> get props => [friendId];
}

class FriendRequestError extends FriendRequestState {
  final String message;

  const FriendRequestError({required this.message});

  @override
  List<Object> get props => [message];
}
