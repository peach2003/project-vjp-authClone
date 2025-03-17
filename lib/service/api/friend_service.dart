import 'package:dio/dio.dart';

class FriendService {
  final Dio _dio = Dio();

  // Lấy danh sách bạn bè
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    try {
      final response = await _dio.get('http://10.0.2.2:3000/friends/list/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // Lấy danh sách user chưa là bạn bè
  Future<List<Map<String, dynamic>>> getUsersNotFriends(int userId) async {
    try {
      final response = await _dio.get('http://10.0.2.2:3000/users/all/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // Gửi lời mời kết bạn
  Future<void> sendFriendRequest(int fromUser, int toUser) async {
    try {
      print("🔹 Gửi lời mời kết bạn từ $fromUser đến $toUser"); // Debug

      final response = await Dio().post(
        "http://10.0.2.2:3000/friends/request",
        data: {
          "fromUser": fromUser,
          "toUser": toUser,
        },
      );

      print("✅ Kết quả: ${response.data}");
    } catch (e) {
      print("❌ Lỗi khi gửi lời mời kết bạn: $e");
    }
  }


  // Lấy danh sách lời mời kết bạn
  Future<List<Map<String, dynamic>>> getPendingRequests(int userId) async {
    try {
      final response = await _dio.get('http://10.0.2.2:3000/friends/pending/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // Chấp nhận lời mời kết bạn
  Future<bool> acceptFriendRequest(int fromUser, int toUser) async {
    try {
      await _dio.post(
        'http://10.0.2.2:3000/friends/accept',
        data: {'fromUser': fromUser, 'toUser': toUser},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Từ chối lời mời kết bạn
  Future<bool> rejectFriendRequest(int fromUser, int toUser) async {
    try {
      await _dio.post(
        'http://10.0.2.2:3000/friends/reject',
        data: {'fromUser': fromUser, 'toUser': toUser},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
