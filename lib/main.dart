import 'package:auth_clone/service/api/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/bloc/language_bloc.dart';
import 'features/home/screens/home_screen.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(">>> Firebase đã được khởi tạo thành công!");
  runApp(
    MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => LanguageBloc()),
      BlocProvider(create: (context) => AuthBloc(AuthService())..add(CheckLoginStatusEvent())), // Kiểm tra đăng nhập
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth System',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: "/login",
        routes: {
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/home": (context) => HomeScreen(), // Trang chính sau khi đăng nhập
        },
      ),
    );
  }
}
