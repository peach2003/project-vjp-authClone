import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _currentMessages = [];

  ChatBloc() : super(ChatInitial()) {
    on<FetchChatHistory>(_onFetchChatHistory);
    on<SendMessage>(_onSendMessage);
    on<AutoRefresh>(_onAutoRefresh);
  }

  Future<void> _onFetchChatHistory(
    FetchChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is! ChatLoaded) {
        emit(ChatLoading());
      }

      final messages = await _chatService.getChatHistory(
        event.currentUserId,
        event.receiverId,
      );

      // Kiểm tra xem có tin nhắn mới không
      if (_currentMessages.isEmpty ||
          messages.length != _currentMessages.length ||
          (messages.isNotEmpty &&
              messages.last['id'] != _currentMessages.last['id'])) {
        _currentMessages = messages;
        emit(ChatLoaded(messages: messages));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final success = await _chatService.sendMessage(
        event.currentUserId,
        event.receiverId,
        event.message,
        event.messageType,
      );

      if (success) {
        emit(ChatMessageSent());
        // Fetch lại tin nhắn sau khi gửi thành công
        add(
          FetchChatHistory(
            currentUserId: event.currentUserId,
            receiverId: event.receiverId,
          ),
        );
      } else {
        emit(ChatError(message: "Không thể gửi tin nhắn"));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onAutoRefresh(
    AutoRefresh event,
    Emitter<ChatState> emit,
  ) async {
    add(
      FetchChatHistory(
        currentUserId: event.currentUserId,
        receiverId: event.receiverId,
      ),
    );
  }
}
