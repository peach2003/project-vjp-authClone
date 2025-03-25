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
}

class ChatMessageSent extends ChatState {}

class ChatUploadLoading extends ChatState {}

class ChatUploadSuccess extends ChatState {
  final Map<String, dynamic> uploadResult;

  const ChatUploadSuccess({required this.uploadResult});

  @override
  List<Object> get props => [uploadResult];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}
