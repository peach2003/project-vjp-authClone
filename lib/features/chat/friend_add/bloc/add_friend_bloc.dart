import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../service/api/friend_service.dart';
import 'add_friend_event.dart';
import 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final FriendService _friendService;

  AddFriendBloc({FriendService? friendService}) 
    : _friendService = friendService ?? FriendService(),
      super(AddFriendInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<SendFriendRequest>(_onSendFriendRequest);
  }

  Future<void> _onFetchUsers(
    FetchUsers event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      emit(AddFriendLoading());
      final users = await _friendService.getUsersNotFriends(event.currentUserId);
      emit(UsersLoaded(users: users, sentRequests: {}));
    } catch (e) {
      emit(AddFriendError('Không thể tải danh sách người dùng: $e'));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      if (state is UsersLoaded) {
        final currentState = state as UsersLoaded;
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? currentUserId = prefs.getInt("userId");

        if (currentUserId == null) {
          emit(AddFriendError('Không tìm thấy userId'));
          return;
        }

        final success = await _friendService.sendFriendRequest(
          currentUserId,
          event.friendId,
        );

        if (success) {
          final newSentRequests = Set<int>.from(currentState.sentRequests)
            ..add(event.friendId);
          
          emit(currentState.copyWith(
            sentRequests: newSentRequests,
          ));
        } else {
          emit(AddFriendError('Không thể gửi lời mời kết bạn'));
        }
      }
    } catch (e) {
      emit(AddFriendError('Lỗi khi gửi lời mời kết bạn: $e'));
    }
  }
}