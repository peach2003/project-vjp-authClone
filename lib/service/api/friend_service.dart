import 'package:dio/dio.dart';

class FriendService {
  final Dio _dio = Dio();
  final String baseUrl = "http://10.0.2.2:3000";

  // Lấy danh sách bạn bè
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/friends/list/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách bạn bè: $e");
      return [];
    }
  }

  // Lấy danh sách nhóm của user
  Future<List<Map<String, dynamic>>> getGroups(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/groups/list/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách nhóm: $e");
      return [];
    }
  }

  // Lấy danh sách user chưa là bạn bè
  Future<List<Map<String, dynamic>>> getUsersNotFriends(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/users/not-friends/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách user chưa là bạn bè: $e");
      return [];
    }
  }

  // Gửi lời mời kết bạn
  Future<void> sendFriendRequest(int fromUser, int toUser) async {
    try {
      await _dio.post(
        "$baseUrl/friends/request",
        data: {"fromUser": fromUser, "toUser": toUser},
      );
    } catch (e) {
      print("❌ Lỗi khi gửi lời mời kết bạn: $e");
    }
  }

  // Lấy danh sách lời mời kết bạn đang chờ xử lý
  Future<List<Map<String, dynamic>>> getPendingRequests(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/friends/pending/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách lời mời kết bạn: $e");
      return [];
    }
  }

  // Chấp nhận lời mời kết bạn
  Future<bool> acceptFriendRequest(int fromUser, int toUser) async {
    try {
      await _dio.post(
        '$baseUrl/friends/accept',
        data: {'fromUser': fromUser, 'toUser': toUser},
      );
      return true;
    } catch (e) {
      print("❌ Lỗi khi chấp nhận lời mời kết bạn: $e");
      return false;
    }
  }

  // Từ chối lời mời kết bạn
  Future<bool> rejectFriendRequest(int fromUser, int toUser) async {
    try {
      await _dio.post(
        '$baseUrl/friends/reject',
        data: {'fromUser': fromUser, 'toUser': toUser},
      );
      return true;
    } catch (e) {
      print("❌ Lỗi khi từ chối lời mời kết bạn: $e");
      return false;
    }
  }
}
