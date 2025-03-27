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
  List<Map<String, dynamic>> _currentMessages = [];

  GroupChatBloc() : super(GroupChatInitial()) {
    on<FetchGroupMessages>(_onFetchGroupMessages);
    on<SendGroupMessage>(_onSendGroupMessage);
    on<SendGroupImageOrVideo>(_onSendGroupImageOrVideo);
    on<SendGroupFile>(_onSendGroupFile);
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
              messages.last['messageId'] !=
                  _currentMessages.last['messageId'])) {
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
        emit(const GroupChatError(message: "Không thể gửi tin nhắn"));
      }
    } catch (e) {
      emit(GroupChatError(message: e.toString()));
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
        emit(GroupChatMessageSent());
        add(FetchGroupMessages(event.groupId));
      } else {
        emit(const GroupChatError(message: "Upload thất bại"));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(GroupChatError(message: e.toString()));
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
        emit(GroupChatMessageSent());
        add(FetchGroupMessages(event.groupId));
      } else {
        emit(const GroupChatError(message: "Upload thất bại"));
      }
    } catch (e) {
      _isUploading = false;
      debugPrint('❌ Upload error: $e');
      emit(GroupChatError(message: e.toString()));
    }
  }

  Future<void> _onAutoRefresh(
    AutoRefresh event,
    Emitter<GroupChatState> emit,
  ) async {
    if (!_isUploading) {
      add(FetchGroupMessages(event.groupId));
    }
  }
}
