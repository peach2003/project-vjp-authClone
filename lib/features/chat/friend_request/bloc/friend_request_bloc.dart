import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/friend_service.dart';
import 'friend_request_event.dart';
import 'friend_request_state.dart';

class FriendRequestBloc extends Bloc<FriendRequestEvent, FriendRequestState> {
  final FriendService _friendService = FriendService();

  FriendRequestBloc() : super(FriendRequestInitial()) {
    on<FetchFriendRequests>(_onFetchFriendRequests);
    on<AcceptRequest>(_onAcceptRequest);
    on<RejectRequest>(_onRejectRequest);
  }

  Future<void> _onFetchFriendRequests(
    FetchFriendRequests event,
    Emitter<FriendRequestState> emit,
  ) async {
    try {
      emit(FriendRequestLoading());
      final requests = await _friendService.getPendingRequests(
        event.currentUserId,
      );
      emit(FriendRequestLoaded(requests: requests));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }

  // Thêm log vào FriendRequestBloc
  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<FriendRequestState> emit,
  ) async {
    try {
      print("🔄 Processing accept request...");
      print("Current state: $state");

      emit(FriendRequestLoading());

      final success = await _friendService.acceptFriendRequest(
        event.currentUserId,
        event.friendId,
      );

      print("✅ Accept result: $success");

      if (success) {
        final requests = await _friendService.getPendingRequests(
          event.currentUserId,
        );
        print("📥 New requests list: $requests");
        emit(FriendRequestLoaded(requests: requests));
      }
    } catch (e) {
      print("❌ Error in _onAcceptRequest: $e");
      emit(FriendRequestError(message: e.toString()));
    }
  }

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<FriendRequestState> emit,
  ) async {
    try {
      emit(FriendRequestLoading());

      final success = await _friendService.rejectFriendRequest(
        event.currentUserId,
        event.friendId,
      );

      if (success) {
        // Sau khi từ chối thành công, cập nhật lại danh sách
        add(FetchFriendRequests(event.currentUserId));
      } else {
        emit(FriendRequestError(message: "Không thể từ chối lời mời"));
      }
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }
}
