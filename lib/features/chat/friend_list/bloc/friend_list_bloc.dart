// lib/features/chat/friend_list/bloc/friend_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/friend_service.dart';
import 'friend_list_event.dart';
import 'friend_list_state.dart';
import 'dart:async';

// lib/features/chat/friend_list/bloc/friend_list_bloc.dart
class FriendListBloc extends Bloc<FriendListEvent, FriendListState> {
  final FriendService _friendService = FriendService();
  Timer? _refreshTimer;
  
  FriendListBloc() : super(FriendListInitial()) {
    on<FetchFriends>(_onFetchFriends);
    on<FetchGroups>(_onFetchGroups);
    on<StartAutoRefresh>(_onStartAutoRefresh);
    on<StopAutoRefresh>(_onStopAutoRefresh);
    
  }

  Future<void> _onFetchFriends(FetchFriends event, Emitter<FriendListState> emit) async {
    try {
      // Chỉ emit loading nếu state hiện tại là initial
      if (state is FriendListInitial) {
        emit(FriendListLoading());
      }
      
      final friends = await _friendService.getFriends(event.currentUserId);
      
      // Kiểm tra state hiện tại
      if (state is FriendListLoaded) {
        final currentState = state as FriendListLoaded;
        emit(FriendListLoaded(
          friends: friends,
          groups: currentState.groups,
        ));
      } else {
        emit(FriendListLoaded(
          friends: friends,
          groups: [],
        ));
      }
    } catch (e) {
      emit(FriendListError(message: e.toString()));
    }
  }

  Future<void> _onFetchGroups(FetchGroups event, Emitter<FriendListState> emit) async {
    try {
      // Chỉ emit loading nếu state hiện tại là initial
      if (state is FriendListInitial) {
        emit(FriendListLoading());
      }
      
      final groups = await _friendService.getGroups(event.currentUserId);
      
      // Kiểm tra state hiện tại
      if (state is FriendListLoaded) {
        final currentState = state as FriendListLoaded;
        emit(FriendListLoaded(
          friends: currentState.friends,
          groups: groups,
        ));
      } else {
        emit(FriendListLoaded(
          friends: [],
          groups: groups,
        ));
      }
    } catch (e) {
      emit(FriendListError(message: e.toString()));
    }
  }

  void _onStartAutoRefresh(StartAutoRefresh event, Emitter<FriendListState> emit) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(FetchFriends(event.currentUserId));
      add(FetchGroups(event.currentUserId));
    });
  }

  void _onStopAutoRefresh(StopAutoRefresh event, Emitter<FriendListState> emit) {
    _refreshTimer?.cancel();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}