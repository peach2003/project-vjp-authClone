import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../service/api/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      final error = await authService.register(event.username, event.password, event.role);
      if (error == null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure(error));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      final userId = await authService.login(event.username, event.password);

      if (userId != null) {
        print("✅ Authenticated với User ID: $userId"); // Debug kiểm tra
        emit(AuthAuthenticated(userId)); // ✅ Trả về userId đúng
      } else {
        print("❌ Lỗi đăng nhập trong AuthBloc");
        emit(AuthFailure("Lỗi đăng nhập"));
      }
    });


    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      await authService.logout();
      emit(AuthInitial()); // Chuyển về trạng thái chưa đăng nhập
    });

    // 🔹 Kiểm tra trạng thái đăng nhập khi mở ứng dụng
    on<CheckLoginStatusEvent>((event, emit) async {
      emit(AuthLoading());
      final userId = await authService.getLoggedInUserId(); // ✅ Dùng đúng hàm lấy `userId`
      if (userId != null) {
        emit(AuthAuthenticated(userId)); // ✅ Trả về `userId` thay vì username (sửa lỗi)
      } else {
        emit(AuthInitial()); // Chưa đăng nhập
      }
    });
  }
}
