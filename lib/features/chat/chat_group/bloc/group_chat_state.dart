import 'package:equatable/equatable.dart';

abstract class GroupChatState {}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final List<Map<String, dynamic>> messages;
  final Map<String, dynamic> pagination;
  final bool isFirstLoad;

  GroupChatLoaded({
    required this.messages,
    required this.pagination,
    this.isFirstLoad = true,
  });

  GroupChatLoaded copyWith({
    List<Map<String, dynamic>>? messages,
    Map<String, dynamic>? pagination,
    bool? isFirstLoad,
  }) {
    return GroupChatLoaded(
      messages: messages ?? this.messages,
      pagination: pagination ?? this.pagination,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
    );
  }
}

class GroupChatError extends GroupChatState {
  final String message;

  GroupChatError(this.message);
}

class GroupChatMessageSent extends GroupChatState {}

class GroupChatUploadLoading extends GroupChatState {}

class GroupChatUploadSuccess extends GroupChatState {
  final Map<String, dynamic> uploadResult;

  GroupChatUploadSuccess({required this.uploadResult});
}
