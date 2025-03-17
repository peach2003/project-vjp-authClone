abstract class AuthState {}

class AuthInitial extends AuthState {}  // Chưa đăng nhập

class AuthLoading extends AuthState {}  // Đang xử lý
// 🔹 Trạng thái chưa đăng nhập
class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}


// 🔹 Trạng thái đã đăng nhập với thông tin user (Fix: Lấy userId thay vì username)
class AuthAuthenticated extends AuthState {
  final int userId;

  AuthAuthenticated(this.userId);

  @override
  List<Object?> get props => [userId];
}
class AuthSuccess extends AuthState {}  // Thành công (Đăng nhập/Đăng ký)

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
