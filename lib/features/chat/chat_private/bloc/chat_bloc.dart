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
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  static const int _messagesPerPage = 10;
  List<Map<String, dynamic>> _allMessages = [];

  ChatBloc() : super(ChatInitial()) {
    on<FetchChatHistory>(_onFetchChatHistory);
    on<LoadMoreMessages>(_onLoadMoreMessages);
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
      if (state is! ChatLoaded) {
        emit(ChatLoading());
      }

      _currentPage = 1;
      _hasMoreMessages = true;
      final response = await _chatService.getChatHistory(
        event.currentUserId,
        event.receiverId,
        page: _currentPage,
        limit: _messagesPerPage,
      );

      final messages = List<Map<String, dynamic>>.from(response['messages']);
      _allMessages = messages;
      _sortMessages();

      emit(
        ChatLoaded(
          messages: _allMessages,
          pagination: response['pagination'],
          isFirstLoad: true,
        ),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (!_hasMoreMessages) return;

    try {
      final currentState = state;
      if (currentState is ChatLoaded) {
        final response = await _chatService.getChatHistory(
          event.currentUserId,
          event.receiverId,
          page: event.page,
          limit: event.limit,
        );

        final newMessages = List<Map<String, dynamic>>.from(
          response['messages'],
        );
        final pagination = response['pagination'];

        _currentPage = pagination['currentPage'];
        _hasMoreMessages = _currentPage < pagination['totalPages'];

        // Thêm tin nhắn mới vào danh sách
        for (var message in newMessages) {
          if (!_allMessages.any((m) => m['id'] == message['id'])) {
            _allMessages.add(message);
          }
        }

        _sortMessages();

        emit(
          ChatLoaded(
            messages: _allMessages,
            pagination: pagination,
            isFirstLoad: false,
          ),
        );
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onAutoRefresh(
    AutoRefresh event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final response = await _chatService.getChatHistory(
        event.currentUserId,
        event.receiverId,
        page: 1,
        limit: _messagesPerPage,
      );

      final latestMessages = List<Map<String, dynamic>>.from(
        response['messages'],
      );
      bool hasNewMessages = false;

      // Kiểm tra và thêm tin nhắn mới
      for (var message in latestMessages) {
        if (!_allMessages.any((m) => m['id'] == message['id'])) {
          _allMessages.add(message);
          hasNewMessages = true;
        }
      }

      if (hasNewMessages) {
        _sortMessages();
        final currentState = state;
        if (currentState is ChatLoaded) {
          emit(
            ChatLoaded(
              messages: _allMessages,
              pagination: currentState.pagination,
              isFirstLoad: false,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('AutoRefresh error: $e');
    }
  }

  void _sortMessages() {
    _allMessages.sort((a, b) {
      DateTime aTime = _parseDateTime(a['created_at']);
      DateTime bTime = _parseDateTime(b['created_at']);
      return bTime.compareTo(aTime); // Sắp xếp giảm dần (mới nhất lên đầu)
    });
  }

  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is String) {
      return DateTime.parse(dateTime).toLocal();
    } else if (dateTime is DateTime) {
      return dateTime.toLocal();
    }
    return DateTime.now().toLocal();
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
