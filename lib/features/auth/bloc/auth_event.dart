abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String role;
  RegisterEvent(this.username, this.password, this.role);
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  LoginEvent(this.username, this.password);
}

class LogoutEvent extends AuthEvent {}  // Sự kiện đăng xuất
// 🔹 Kiểm tra trạng thái đăng nhập khi mở ứng dụng
class CheckLoginStatusEvent extends AuthEvent {}