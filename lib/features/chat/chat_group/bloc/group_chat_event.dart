import 'package:equatable/equatable.dart';

abstract class GroupChatEvent {}

class FetchGroupChatHistory extends GroupChatEvent {
  final int groupId;

  FetchGroupChatHistory({required this.groupId});
}

class LoadMoreGroupMessages extends GroupChatEvent {
  final int groupId;
  final int page;
  final int limit;

  LoadMoreGroupMessages({
    required this.groupId,
    required this.page,
    required this.limit,
  });
}

class SendGroupMessage extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String message;
  final String messageType;

  SendGroupMessage({
    required this.groupId,
    required this.senderId,
    required this.message,
    required this.messageType,
  });
}

class SendGroupImageOrVideo extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String filePath;

  SendGroupImageOrVideo({
    required this.groupId,
    required this.senderId,
    required this.filePath,
  });
}

class SendGroupFile extends GroupChatEvent {
  final int groupId;
  final int senderId;
  final String filePath;

  SendGroupFile({
    required this.groupId,
    required this.senderId,
    required this.filePath,
  });
}

class AutoRefreshGroup extends GroupChatEvent {
  final int groupId;

  AutoRefreshGroup({required this.groupId});
}
