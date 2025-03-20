import 'package:equatable/equatable.dart';

abstract class AddFriendEvent extends Equatable {
  const AddFriendEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends AddFriendEvent {
  final int currentUserId;
  const FetchUsers(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class SendFriendRequest extends AddFriendEvent {
  final int friendId;
  const SendFriendRequest(this.friendId);

  @override
  List<Object> get props => [friendId];
}