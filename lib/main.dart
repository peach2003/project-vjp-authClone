import 'package:auth_clone/service/api/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/navbar/bottom_navbar.dart';
import 'firebase_options.dart';
import 'features/auth/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(">>> Firebase đã được khởi tạo thành công!");
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(AuthService())..add(CheckLoginStatusEvent()),
        ), // Kiểm tra đăng nhập
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => BottomNavbar(currentUserId: 0), // ✅ Sẽ được cập nhật từ AuthWrapper
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          print("✅ Chuyển sang BottomNavbar với User ID: ${state.userId}");
          return BottomNavbar(currentUserId: state.userId); // ✅ Truyền `currentUserId`
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
