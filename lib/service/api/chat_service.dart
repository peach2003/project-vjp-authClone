import 'package:dio/dio.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  // 🔹 Gửi tin nhắn giữa 2 người
  Future<bool> sendMessage(int sender, int receiver, String message, String messageType) async {
    try {
      await _dio.post("/chat/send", data: {
        "sender": sender,
        "receiver": receiver,
        "message": message,
        "message_type": messageType,
      });
      return true;
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn: $e");
      return false;
    }
  }

  // 🔹 Lấy lịch sử tin nhắn giữa 2 người
  Future<List<Map<String, dynamic>>> getChatHistory(int sender, int receiver) async {
    try {
      final response = await _dio.get("/chat/history", queryParameters: {
        "sender": sender,
        "receiver": receiver,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy lịch sử chat: $e");
      return [];
    }
  }

  // 🔹 Đánh dấu tin nhắn đã xem
  Future<bool> markMessagesAsSeen(int userId, int chatPartnerId) async {
    try {
      await _dio.post("/chat/seen", data: {
        "userId": userId,
        "chatPartnerId": chatPartnerId,
      });
      return true;
    } catch (e) {
      print("❌ Lỗi khi đánh dấu tin nhắn đã xem: $e");
      return false;
    }
  }
}
