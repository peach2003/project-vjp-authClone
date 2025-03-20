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

    if (messages.isNotEmpty && other.messages.isNotEmpty) {
      return messages.last['id'] != other.messages.last['id'];
    }

    return false;
  }

  GroupChatLoaded copyWith({List<Map<String, dynamic>>? messages}) {
    return GroupChatLoaded(messages: messages ?? this.messages);
  }
}

class GroupChatMessageSent extends GroupChatState {}

class GroupChatError extends GroupChatState {
  final String message;

  const GroupChatError({required this.message});

  @override
  List<Object> get props => [message];
}
