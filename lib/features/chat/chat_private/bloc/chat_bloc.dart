import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service/api/chat_service.dart';
import '../../../../service/api/upload_service.dart';
import 'package:flutter/foundation.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  final UploadService _uploadService = UploadService();
  bool _isUploading = false;

  ChatBloc() : super(ChatInitial()) {
    on<FetchChatHistory>(_onFetchChatHistory);
    on<SendMessage>(_onSendMessage);
    on<AutoRefresh>(_onAutoRefresh);
    on<SendImageOrVideo>(_onSendImageOrVideo);
    on<SendFile>(_onSendFile);
  }

  Future<void> _onFetchChatHistory(
    FetchChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final messages = await _chatService.getChatHistory(
        event.currentUserId,
        event.receiverId,
      );
      emit(ChatLoaded(messages: messages));
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
      } else {
        emit(const ChatError(message: "Không thể gửi tin nhắn"));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onAutoRefresh(
    AutoRefresh event,
    Emitter<ChatState> emit,
  ) async {
    if (!_isUploading) {
      add(
        FetchChatHistory(
          currentUserId: event.currentUserId,
          receiverId: event.receiverId,
        ),
      );
    }
  }

  Future<void> _onSendImageOrVideo(
    SendImageOrVideo event,
    Emitter<ChatState> emit,
  ) async {
    if (_isUploading) {
      debugPrint("⚠️ Đang có upload khác, bỏ qua request này");
      return;
    }

    try {
      _isUploading = true;
      debugPrint('🔷 Processing SendImageOrVideo event');
      emit(ChatUploadLoading());

      final uploadResult = await _uploadService.uploadImageOrVideo(
        filePath: event.filePath,
        sender: event.currentUserId,
        receiver: event.receiverId,
      );

      _isUploading = false;

      if (uploadResult != null) {
        debugPrint('✅ Upload success: $uploadResult');
        // Server đã tự động lưu tin nhắn vào DB, không cần gọi sendMessage nữa
        emit(ChatMessageSent());

        // Refresh lại danh sách tin nhắn
        add(
          FetchChatHistory(
            currentUserId: event.currentUserId,
            receiverId: event.receiverId,
          ),
        );
      } else {
        emit(const ChatError(message: "Upload thất bại"));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendFile(SendFile event, Emitter<ChatState> emit) async {
    if (_isUploading) {
      debugPrint("⚠️ Đang có upload khác, bỏ qua request này");
      return;
    }

    try {
      _isUploading = true;
      debugPrint('🔷 Processing SendFile event');
      emit(ChatUploadLoading());

      final uploadResult = await _uploadService.uploadFile(
        filePath: event.filePath,
        sender: event.currentUserId,
        receiver: event.receiverId,
      );

      _isUploading = false;

      if (uploadResult != null) {
        debugPrint('✅ Upload success: $uploadResult');
        // Server đã tự động lưu tin nhắn vào DB, không cần gọi sendMessage nữa
        emit(ChatMessageSent());

        // Refresh lại danh sách tin nhắn
        add(
          FetchChatHistory(
            currentUserId: event.currentUserId,
            receiverId: event.receiverId,
          ),
        );
      } else {
        emit(const ChatError(message: "Upload thất bại"));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(ChatError(message: e.toString()));
    }
  }
}
