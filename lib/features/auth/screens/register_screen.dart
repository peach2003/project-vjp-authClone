import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = "doanh_nghiep";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2), // 🌿 Màu nền nhẹ nhàng
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Tiêu đề
              Text(
                "Đăng ký tài khoản",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

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

              SizedBox(height: 12),

              // 🔹 Chọn vai trò
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    items: [
                      "doanh_nghiep",
                      "chuyen_gia",
                      "tu_van_vien",
                      "operator"
                    ]
                        .map(
                          (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.replaceAll("_", " ").toUpperCase()),
                      ),
                    )
                        .toList(),
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🔹 Nút Đăng ký
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("✅ Đăng ký thành công")),
                    );
                    Navigator.pop(context);
                  }
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ ${state.error}")),
                    );
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        RegisterEvent(
                          usernameController.text,
                          passwordController.text,
                          selectedRole,
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
                        : Text(
                      "Đăng ký",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  );
                },
              ),

              SizedBox(height: 12),

              // 🔹 Chuyển đến trang đăng nhập
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Đã có tài khoản? Đăng nhập ngay",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
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
}
