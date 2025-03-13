abstract class AuthState {}

class AuthInitial extends AuthState {}  // Chưa đăng nhập

class AuthLoading extends AuthState {}  // Đang xử lý
// 🔹 Trạng thái chưa đăng nhập
class AuthUnauthenticated extends AuthState {}


// 🔹 Trạng thái đã đăng nhập với thông tin user
class AuthAuthenticated extends AuthState {
  final String username;

  AuthAuthenticated(this.username);

  @override
  List<Object> get props => [username];
}

class AuthSuccess extends AuthState {}  // Thành công (Đăng nhập/Đăng ký)

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
