import 'package:equatable/equatable.dart';

abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final List<Map<String, dynamic>> messages;

  const GroupChatLoaded({required this.messages});

  @override
  List<Object> get props => [messages];

  bool hasNewMessages(GroupChatLoaded other) {
    if (messages.length != other.messages.length) return true;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i]["messageId"] != other.messages[i]["messageId"]) {
        return true;
      }
    }
    return false;
  }

  GroupChatLoaded copyWith({List<Map<String, dynamic>>? messages}) {
    return GroupChatLoaded(messages: messages ?? this.messages);
  }
}

class GroupChatMessageSent extends GroupChatState {}

class GroupChatUploadLoading extends GroupChatState {}

class GroupChatUploadSuccess extends GroupChatState {
  final Map<String, dynamic> uploadResult;

  const GroupChatUploadSuccess({required this.uploadResult});

  @override
  List<Object> get props => [uploadResult];
}

class GroupChatError extends GroupChatState {
  final String message;

  const GroupChatError({required this.message});

  @override
  List<Object> get props => [message];
}
