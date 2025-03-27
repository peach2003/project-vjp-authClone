import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../service/api/group_service.dart';
import '../../../../service/api/group_upload_service.dart';
import 'group_chat_event.dart';
import 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final GroupService _groupService = GroupService();
  final GroupUploadService _uploadService = GroupUploadService();
  bool _isUploading = false;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  static const int _messagesPerPage = 10;
  List<Map<String, dynamic>> _allMessages = [];

  GroupChatBloc() : super(GroupChatInitial()) {
    on<FetchGroupChatHistory>(_onFetchGroupChatHistory);
    on<LoadMoreGroupMessages>(_onLoadMoreGroupMessages);
    on<SendGroupMessage>(_onSendGroupMessage);
    on<SendGroupImageOrVideo>(_onSendGroupImageOrVideo);
    on<SendGroupFile>(_onSendGroupFile);
    on<AutoRefreshGroup>(_onAutoRefreshGroup);
  }

  Future<void> _onFetchGroupChatHistory(
    FetchGroupChatHistory event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      if (state is! GroupChatLoaded) {
        emit(GroupChatLoading());
      }
      _currentPage = 1;
      _hasMoreMessages = true;
      _allMessages = [];

      final result = await _groupService.getGroupMessages(
        event.groupId,
        page: _currentPage,
        limit: _messagesPerPage,
      );

      final messages = List<Map<String, dynamic>>.from(result['messages']);
      _allMessages = _sortMessages(messages);

      emit(
        GroupChatLoaded(
          messages: _allMessages,
          pagination: result['pagination'],
          isFirstLoad: true,
        ),
      );
    } catch (e) {
      emit(GroupChatError('Lỗi khi tải lịch sử chat: $e'));
    }
  }

  Future<void> _onLoadMoreGroupMessages(
    LoadMoreGroupMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    if (!_hasMoreMessages) return;

    try {
      final result = await _groupService.getGroupMessages(
        event.groupId,
        page: event.page,
        limit: event.limit,
      );

      final newMessages = List<Map<String, dynamic>>.from(result['messages']);
      _allMessages.addAll(_sortMessages(newMessages));

      _hasMoreMessages = event.page < result['pagination']['totalPages'];
      _currentPage = event.page;

      emit(
        GroupChatLoaded(
          messages: _allMessages,
          pagination: result['pagination'],
          isFirstLoad: false,
        ),
      );
    } catch (e) {
      emit(GroupChatError('Lỗi khi tải thêm tin nhắn: $e'));
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
        event.messageType,
      );

      if (success) {
        emit(GroupChatMessageSent());
        add(FetchGroupChatHistory(groupId: event.groupId));
      } else {
        emit(GroupChatError('Không thể gửi tin nhắn'));
      }
    } catch (e) {
      emit(GroupChatError('Lỗi khi gửi tin nhắn: $e'));
    }
  }

  Future<void> _onSendGroupImageOrVideo(
    SendGroupImageOrVideo event,
    Emitter<GroupChatState> emit,
  ) async {
    if (_isUploading) {
      debugPrint("⚠️ Đang có upload khác, bỏ qua request này");
      return;
    }

    try {
      _isUploading = true;
      debugPrint('🔷 Processing SendGroupImageOrVideo event');
      emit(GroupChatUploadLoading());

      final uploadResult = await _uploadService.uploadGroupImageOrVideo(
        filePath: event.filePath,
        sender: event.senderId,
        groupId: event.groupId,
      );

      _isUploading = false;

      if (uploadResult != null) {
        debugPrint('✅ Upload success: $uploadResult');
        emit(GroupChatUploadSuccess(uploadResult: uploadResult));
        add(FetchGroupChatHistory(groupId: event.groupId));
      } else {
        emit(GroupChatError('Upload thất bại'));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(GroupChatError('Lỗi khi gửi file: $e'));
    }
  }

  Future<void> _onSendGroupFile(
    SendGroupFile event,
    Emitter<GroupChatState> emit,
  ) async {
    if (_isUploading) {
      debugPrint("⚠️ Đang có upload khác, bỏ qua request này");
      return;
    }

    try {
      _isUploading = true;
      debugPrint('🔷 Processing SendGroupFile event');
      emit(GroupChatUploadLoading());

      final uploadResult = await _uploadService.uploadGroupFile(
        filePath: event.filePath,
        sender: event.senderId,
        groupId: event.groupId,
      );

      _isUploading = false;

      if (uploadResult != null) {
        debugPrint('✅ Upload success: $uploadResult');
        emit(GroupChatUploadSuccess(uploadResult: uploadResult));
        add(FetchGroupChatHistory(groupId: event.groupId));
      } else {
        emit(GroupChatError('Upload thất bại'));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(GroupChatError('Lỗi khi gửi file: $e'));
    }
  }

  Future<void> _onAutoRefreshGroup(
    AutoRefreshGroup event,
    Emitter<GroupChatState> emit,
  ) async {
    if (_isUploading) return;

    try {
      final result = await _groupService.getGroupMessages(
        event.groupId,
        page: 1,
        limit: _messagesPerPage,
      );

      final newMessages = List<Map<String, dynamic>>.from(result['messages']);
      final currentState = state;

      if (currentState is GroupChatLoaded) {
        if (_hasNewMessages(currentState.messages, newMessages)) {
          _allMessages = _sortMessages(newMessages);
          emit(
            GroupChatLoaded(
              messages: _allMessages,
              pagination: result['pagination'],
              isFirstLoad: false,
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi refresh: $e');
    }
  }

  List<Map<String, dynamic>> _sortMessages(
    List<Map<String, dynamic>> messages,
  ) {
    messages.sort((a, b) {
      final aDate = DateTime.parse(a['created_at']);
      final bDate = DateTime.parse(b['created_at']);
      return bDate.compareTo(aDate);
    });
    return messages;
  }

  bool _hasNewMessages(
    List<Map<String, dynamic>> currentMessages,
    List<Map<String, dynamic>> newMessages,
  ) {
    if (currentMessages.length != newMessages.length) return true;
    for (int i = 0; i < currentMessages.length; i++) {
      if (currentMessages[i]['id'] != newMessages[i]['id']) {
        return true;
      }
    }
    return false;
  }
}
