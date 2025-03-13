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
      final error = await authService.login(event.username, event.password);
      if (error == null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure(error));
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
      final username = await authService.getLoggedInUser();
      if (username != null) {
        emit(AuthAuthenticated(username));
      } else {
        emit(AuthInitial()); // Chưa đăng nhập
      }
    });
  }
}
