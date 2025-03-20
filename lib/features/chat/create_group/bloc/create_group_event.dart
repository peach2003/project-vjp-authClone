import 'package:equatable/equatable.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object> get props => [];
}

class FetchFriends extends CreateGroupEvent {
  final int currentUserId;

  const FetchFriends(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}

class CreateGroup extends CreateGroupEvent {
  final int currentUserId;
  final String groupName;
  final List<int> memberIds;

  const CreateGroup({
    required this.currentUserId,
    required this.groupName,
    required this.memberIds,
  });

  @override
  List<Object> get props => [currentUserId, groupName, memberIds];
}

class AddMember extends CreateGroupEvent {
  final int memberId;

  const AddMember(this.memberId);

  @override
  List<Object> get props => [memberId];
}

class RemoveMember extends CreateGroupEvent {
  final int memberId;

  const RemoveMember(this.memberId);

  @override
  List<Object> get props => [memberId];
}

class UpdateGroupName extends CreateGroupEvent {
  final String name;

  const UpdateGroupName(this.name);

  @override
  List<Object> get props => [name];
}
class InitializeGroup extends CreateGroupEvent {
  final int currentUserId;

  const InitializeGroup(this.currentUserId);

  @override
  List<Object> get props => [currentUserId];
}