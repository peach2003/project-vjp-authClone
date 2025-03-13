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
      appBar: AppBar(title: Text("Đăng ký")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đăng ký thành công")));
            Navigator.pop(context);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              TextField(controller: usernameController, decoration: InputDecoration(labelText: "Tên đăng nhập")),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: "Mật khẩu"), obscureText: true),
              DropdownButton<String>(
                value: selectedRole,
                items: ["doanh_nghiep", "chuyen_gia", "tu_van_vien", "operator"]
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(RegisterEvent(usernameController.text, passwordController.text, selectedRole));
                },
                child: state is AuthLoading ? CircularProgressIndicator() : Text("Đăng ký"),
              ),
            ],
          );
        },
      ),
    );
  }
}
