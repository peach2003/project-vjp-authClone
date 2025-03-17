import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service/api/google_auth_service.dart';
import '../../navbar/bottom_navbar.dart';
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
      backgroundColor: Color(0xFFF2F2F2), // Màu nền nhẹ nhàng
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Avatar & Tiêu đề
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.lock, color: Colors.white, size: 50),
              ),
              SizedBox(height: 16),
              Text(
                "Chào mừng trở lại!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // 🔹 Ô nhập tên đăng nhập
              _buildInputField(
                controller: usernameController,
                hintText: "Tên đăng nhập",
                icon: Icons.person_outline,
              ),

              // 🔹 Ô nhập mật khẩu
              _buildInputField(
                controller: passwordController,
                hintText: "Mật khẩu",
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              SizedBox(height: 20),

              // 🔹 Nút Đăng nhập
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BottomNavbar(currentUserId: state.userId),
                      ),
                    );
                  }
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          usernameController.text,
                          passwordController.text,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: state is AuthLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Đăng nhập",
                        style:
                        TextStyle(fontSize: 16, color: Colors.white)),
                  );
                },
              ),

              SizedBox(height: 12),

              // 🔹 Chuyển đến trang đăng ký
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/register");
                },
                child: Text(
                  "Chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),

              SizedBox(height: 20),

              // 🔹 Nút Đăng nhập với Google
              _buildGoogleLoginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Widget Ô nhập liệu
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔹 Nút đăng nhập với Google
  Widget _buildGoogleLoginButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset("assets/images/google.png", height: 24),
      label: Text(
        "Đăng nhập với Google",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: () async {
        int? userId = await _googleAuthService.signInWithGoogle();
        if (userId != null) {
          print("🎯 Đăng nhập Google thành công! Chuyển đến Home với userId: $userId");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavbar(currentUserId: userId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Lỗi đăng nhập Google")),
          );
        }
      },
    );
  }
}
