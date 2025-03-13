import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service/api/google_auth_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, "/home");
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Tên đăng nhập"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Mật khẩu"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginEvent(
                        usernameController.text,
                        passwordController.text,
                      ),
                    );
                  },
                  child:
                      state is AuthLoading
                          ? CircularProgressIndicator()
                          : Text("Đăng nhập"),
                ),
                SizedBox(height: 10), // Khoảng cách
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/register",
                    ); // Chuyển sang màn hình đăng ký
                  },
                  child: Text("Chưa có tài khoản? Đăng ký ngay"),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text("Đăng nhập với Google"),
                  onPressed: () async {
                    String? error = await _googleAuthService.signInWithGoogle();
                    if (error == null) {
                      Navigator.pushReplacementNamed(context, "/home");
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
