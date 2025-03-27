import 'package:equatable/equatable.dart';

abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object> get props => [];
}

class FetchGroupMessages extends GroupChatEvent {
  final int groupId;

  const FetchGroupMessages(this.groupId);

  @override
  List<Object> get props => [groupId];
}

class SendGroupMessage extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String message;

  const SendGroupMessage({
    required this.groupId,
    required this.senderId,
    required this.message,
  });

  @override
  List<Object> get props => [groupId, senderId, message];
}

class SendGroupImageOrVideo extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String filePath;

  const SendGroupImageOrVideo({
    required this.groupId,
    required this.senderId,
    required this.filePath,
  });

  @override
  List<Object> get props => [groupId, senderId, filePath];
}

class SendGroupFile extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String filePath;

  const SendGroupFile({
    required this.groupId,
    required this.senderId,
    required this.filePath,
  });

  @override
  List<Object> get props => [groupId, senderId, filePath];
}

class AutoRefresh extends GroupChatEvent {
  final int groupId;

  const AutoRefresh(this.groupId);

  @override
  List<Object> get props => [groupId];
}
