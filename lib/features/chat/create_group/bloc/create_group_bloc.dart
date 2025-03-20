import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/group_service.dart';
import '../../../../service/api/friend_service.dart';
import 'create_group_event.dart';
import 'create_group_state.dart';
import 'package:flutter/material.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final GroupService _groupService = GroupService();
  final FriendService _friendService = FriendService();
  final TextEditingController groupNameController = TextEditingController();
  final List<Map<String, dynamic>> friends = [];
  final List<int> selectedFriends = [];
  
  CreateGroupBloc() : super(CreateGroupInitial()) {
    on<InitializeGroup>(_onInitializeGroup);
    on<FetchFriends>(_onFetchFriends);
    on<CreateGroup>(_onCreateGroup);
    on<AddMember>(_onAddMember);
    on<RemoveMember>(_onRemoveMember);
    on<UpdateGroupName>(_onUpdateGroupName);
  }

  Future<void> _onInitializeGroup(InitializeGroup event, Emitter<CreateGroupState> emit) async {
    groupNameController.addListener(() {
      add(UpdateGroupName(groupNameController.text));
    });
    add(FetchFriends(event.currentUserId));
  }

  Future<void> _onFetchFriends(FetchFriends event, Emitter<CreateGroupState> emit) async {
    try {
      emit(CreateGroupLoading());
      final friends = await _friendService.getFriends(event.currentUserId);
      emit(FriendsLoaded(
        friends: friends,
        selectedFriends: [],
        groupName: '',
      ));
    } catch (e) {
      emit(CreateGroupError(message: e.toString()));
    }
  }

  void _onAddMember(AddMember event, Emitter<CreateGroupState> emit) {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      final updatedSelectedFriends = List<int>.from(currentState.selectedFriends)
        ..add(event.memberId);
      emit(currentState.copyWith(selectedFriends: updatedSelectedFriends));
    }
  }

  void _onRemoveMember(RemoveMember event, Emitter<CreateGroupState> emit) {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      final updatedSelectedFriends = List<int>.from(currentState.selectedFriends)
        ..remove(event.memberId);
      emit(currentState.copyWith(selectedFriends: updatedSelectedFriends));
    }
  }

  void _onUpdateGroupName(UpdateGroupName event, Emitter<CreateGroupState> emit) {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      emit(currentState.copyWith(groupName: event.name));
    }
  }

  Future<void> _onCreateGroup(CreateGroup event, Emitter<CreateGroupState> emit) async {
    try {
      if (event.groupName.isEmpty) {
        emit(CreateGroupError(message: 'Vui lòng nhập tên nhóm'));
        return;
      }

      if (event.memberIds.isEmpty) {
        emit(CreateGroupError(message: 'Vui lòng chọn ít nhất một thành viên'));
        return;
      }

      emit(CreateGroupLoading());
      
      final groupId = await _groupService.createGroup(
        event.groupName,
        event.memberIds,
        event.currentUserId,
      );
      
      if (groupId != null) {
        emit(CreateGroupSuccess(groupId: groupId));
      } else {
        emit(CreateGroupError(message: "Không thể tạo nhóm"));
      }
    } catch (e) {
      emit(CreateGroupError(message: e.toString()));
    }
  }
}