import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  // Đăng ký tài khoản
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
  Future<String?> getLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  // Đăng nhập
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post("/login", data: {
        "username": username,
        "password": password,
      });

      String token = response.data['token'] ?? "";
      String role = response.data['role'] ?? "unknown";

      // Lưu token, username, role vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("username", username);
      await prefs.setString("role", role);
      print("🔹 Lưu vào SharedPreferences: Role = $role");
      return null; // Thành công
    } catch (e) {
      return "Lỗi đăng nhập: $e";
    }
  }
  // Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post("/logout"); // Gửi request đến server (có thể không cần)

      // Xóa dữ liệu đăng nhập khỏi SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      await prefs.remove("username");
      await prefs.remove("role");
    } catch (e) {
      print("❌ Lỗi đăng xuất: $e");
    }
  }

  // **Lấy danh sách user từ server**
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _dio.get("/users");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // **Cập nhật quyền user**
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
