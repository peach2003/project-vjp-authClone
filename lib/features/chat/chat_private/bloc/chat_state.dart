import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object> get props => [messages];

  bool hasNewMessages(ChatLoaded other) {
    if (messages.length != other.messages.length) return true;

    if (messages.isNotEmpty && other.messages.isNotEmpty) {
      return messages.last['id'] != other.messages.last['id'];
    }

    return false;
  }

  ChatLoaded copyWith({List<Map<String, dynamic>>? messages}) {
    return ChatLoaded(messages: messages ?? this.messages);
  }
}

class ChatMessageSent extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}
