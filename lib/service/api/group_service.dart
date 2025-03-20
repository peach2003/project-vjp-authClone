import 'package:dio/dio.dart';

class GroupService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  /// 🔹 **Tạo nhóm chat**
  Future<int?> createGroup(
    String groupName,
    List<int> memberIds,
    int creatorId,
  ) async {
    try {
      print("📤 Đang tạo nhóm mới: $groupName");
      final response = await _dio.post(
        "/group/create",
        data: {"name": groupName, "members": memberIds, "creatorId": creatorId},
      );

      if (response.statusCode == 200) {
        print("✅ Nhóm tạo thành công! Group ID: ${response.data['groupId']}");
        return response.data["groupId"];
      } else {
        print("❌ Lỗi từ server: ${response.data['error']}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi khi tạo nhóm: $e");
      return null;
    }
  }

  /// 🔹 **Lấy danh sách nhóm của user**
  Future<List<Map<String, dynamic>>> getUserGroups(int userId) async {
    try {
      print("📤 Đang lấy danh sách nhóm từ server...");
      final response = await _dio.get("/groups/list/$userId");
      print("✅ Response từ server: ${response.data}");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách nhóm: $e");
      return [];
    }
  }

  /// 🔹 **Gửi tin nhắn trong nhóm**
  Future<bool> sendGroupMessage(
    int groupId,
    int senderId,
    String message,
  ) async {
    try {
      print("📤 Đang gửi tin nhắn nhóm...");
      await _dio.post(
        "/group/send-message",
        data: {"groupId": groupId, "sender": senderId, "message": message},
      );
      print("✅ Gửi tin nhắn nhóm thành công!");
      return true;
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn nhóm: $e");
      return false;
    }
  }

  /// 🔹 **Lấy lịch sử tin nhắn trong nhóm**
  Future<List<Map<String, dynamic>>> getGroupMessages(int groupId) async {
    try {
      print("📤 Đang lấy lịch sử tin nhắn nhóm...");
      final response = await _dio.get("/group/messages/$groupId");
      print("✅ Response từ server: ${response.data}");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("❌ Lỗi khi lấy lịch sử tin nhắn nhóm: $e");
      return [];
    }
  }
}
