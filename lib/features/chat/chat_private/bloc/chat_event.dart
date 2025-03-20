import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class FetchChatHistory extends ChatEvent {
  final int currentUserId;
  final int receiverId;

  const FetchChatHistory({
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  List<Object> get props => [currentUserId, receiverId];
}

class SendMessage extends ChatEvent {
  final int currentUserId;
  final int receiverId;
  final String message;
  final String messageType;

  const SendMessage({
    required this.currentUserId,
    required this.receiverId,
    required this.message,
    required this.messageType,
  });

  @override
  List<Object> get props => [currentUserId, receiverId, message, messageType];
}

class AutoRefresh extends ChatEvent {
  final int currentUserId;
  final int receiverId;

  const AutoRefresh({
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  List<Object> get props => [currentUserId, receiverId];
}