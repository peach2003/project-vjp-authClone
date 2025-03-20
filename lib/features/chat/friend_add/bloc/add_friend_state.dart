import 'package:equatable/equatable.dart';

abstract class AddFriendState extends Equatable {
  const AddFriendState();

  @override
  List<Object> get props => [];
}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class UsersLoaded extends AddFriendState {
  final List<Map<String, dynamic>> users;
  final Set<int> sentRequests;

  const UsersLoaded({
    required this.users,
    required this.sentRequests,
  });

  @override
  List<Object> get props => [users, sentRequests];

  UsersLoaded copyWith({
    List<Map<String, dynamic>>? users,
    Set<int>? sentRequests,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      sentRequests: sentRequests ?? this.sentRequests,
    );
  }
}

class AddFriendError extends AddFriendState {
  final String message;
  const AddFriendError(this.message);

  @override
  List<Object> get props => [message];
}