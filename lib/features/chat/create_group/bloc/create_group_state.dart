import 'package:equatable/equatable.dart';

abstract class CreateGroupState extends Equatable {
  const CreateGroupState();

  @override
  List<Object> get props => [];
}

class CreateGroupInitial extends CreateGroupState {}

class CreateGroupLoading extends CreateGroupState {}

class FriendsLoaded extends CreateGroupState {
  final List<Map<String, dynamic>> friends;
  final List<int> selectedFriends;
  final String groupName;

  const FriendsLoaded({
    required this.friends,
    required this.selectedFriends,
    required this.groupName,
  });

  @override
  List<Object> get props => [friends, selectedFriends, groupName];

  FriendsLoaded copyWith({
    List<Map<String, dynamic>>? friends,
    List<int>? selectedFriends,
    String? groupName,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      selectedFriends: selectedFriends ?? this.selectedFriends,
      groupName: groupName ?? this.groupName,
    );
  }
}

class CreateGroupSuccess extends CreateGroupState {
  final int groupId;

  const CreateGroupSuccess({required this.groupId});

  @override
  List<Object> get props => [groupId];
}

class CreateGroupError extends CreateGroupState {
  final String message;

  const CreateGroupError({required this.message});

  @override
  List<Object> get props => [message];
}