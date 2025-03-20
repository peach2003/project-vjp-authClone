import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/group_service.dart';
import 'group_chat_event.dart';
import 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> _currentMessages = [];

  GroupChatBloc() : super(GroupChatInitial()) {
    on<FetchGroupMessages>(_onFetchGroupMessages);
    on<SendGroupMessage>(_onSendGroupMessage);
    on<AutoRefresh>(_onAutoRefresh);
  }

  Future<void> _onFetchGroupMessages(
    FetchGroupMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      if (state is! GroupChatLoaded) {
        emit(GroupChatLoading());
      }

      final messages = await _groupService.getGroupMessages(event.groupId);

      // Kiểm tra xem có tin nhắn mới không
      if (_currentMessages.isEmpty ||
          messages.length != _currentMessages.length ||
          (messages.isNotEmpty &&
              messages.last['id'] != _currentMessages.last['id'])) {
        _currentMessages = messages;
        emit(GroupChatLoaded(messages: messages));
      }
    } catch (e) {
      emit(GroupChatError(message: e.toString()));
    }
  }

  Future<void> _onSendGroupMessage(
    SendGroupMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      final success = await _groupService.sendGroupMessage(
        event.groupId,
        event.senderId,
        event.message,
      );

      if (success) {
        emit(GroupChatMessageSent());
        // Fetch lại tin nhắn sau khi gửi thành công
        add(FetchGroupMessages(event.groupId));
      } else {
        emit(GroupChatError(message: "Không thể gửi tin nhắn"));
      }
    } catch (e) {
      emit(GroupChatError(message: e.toString()));
    }
  }

  Future<void> _onAutoRefresh(
    AutoRefresh event,
    Emitter<GroupChatState> emit,
  ) async {
    add(FetchGroupMessages(event.groupId));
  }
}
