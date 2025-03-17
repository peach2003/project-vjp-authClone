import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  // 🔹 Đăng ký tài khoản
  Future<String?> register(String username, String password, String role) async {
    try {
      final response = await _dio.post("/register", data: {
        "username": username,
        "password": password,
        "role": role,
      });

      return response.data['message']; // Trả về thông báo đăng ký thành công
    } catch (e) {
      return "Lỗi đăng ký: $e";
    }
  }

  // 🔹 Kiểm tra user có đăng nhập hay không
  Future<int?> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  // 🔹 Đăng nhập
  Future<int?> login(String username, String password) async {
    try {
      final response = await _dio.post("/login", data: {
        "username": username,
        "password": password,
      });

      print("🔹 API Response: ${response.data}"); // Debug xem API trả về gì

      int? userId = response.data['userId']; // ✅ Đảm bảo API trả về userId hợp lệ

      if (userId == null || userId == 0) {
        print("❌ Lỗi: API không trả về userId hợp lệ");
        return null;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt("userId", userId); // ✅ Lưu userId
      await prefs.setString("token", response.data['token'] ?? "");
      await prefs.setString("username", username);
      await prefs.setString("role", response.data['role'] ?? "unknown");

      print("✅ Đăng nhập thành công! User ID: $userId");
      return userId;
    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      return null;
    }
  }



  // 🔹 Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post("/logout"); // Gửi request đến server (có thể không cần)

      // Xóa dữ liệu đăng nhập khỏi SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      await prefs.remove("userId");
      await prefs.remove("username");
      await prefs.remove("role");
      print("✅ Đăng xuất thành công!");
    } catch (e) {
      print("❌ Lỗi đăng xuất: $e");
    }
  }

  // 🔹 Lấy danh sách user từ server
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // 🔹 Cập nhật quyền user
  Future<bool> updateUserRole(String username, String newRole) async {
    try {
      await _dio.put("/update-role", data: {
        "username": username,
        "role": newRole,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
