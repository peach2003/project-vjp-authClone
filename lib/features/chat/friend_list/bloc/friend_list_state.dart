// lib/features/chat/friend_list/bloc/friend_list_state.dart
import 'package:equatable/equatable.dart';

abstract class FriendListState extends Equatable {
  const FriendListState();

  @override
  List<Object> get props => [];
}

class FriendListInitial extends FriendListState {}

class FriendListLoading extends FriendListState {}

class FriendListLoaded extends FriendListState {
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> groups;

  const FriendListLoaded({
    required this.friends,
    required this.groups,
  });

  @override
  List<Object> get props => [friends, groups];
}

class FriendListError extends FriendListState {
  final String message;

  const FriendListError({required this.message});

  @override
  List<Object> get props => [message];
}