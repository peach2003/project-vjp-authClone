import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Đăng nhập bị hủy";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return "Lỗi xác thực Google";

      String email = user.email!;
      String uid = user.uid;

      // Gửi thông tin đăng nhập lên server
      Response response = await _dio.post(
        "/google-login",
        data: {"email": email, "uid": uid},
      );

      if (response.statusCode == 200) {
        String token = response.data["token"];
        String role = response.data["role"];

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("username", email);
        await prefs.setString("role", role);

        return null; // Đăng nhập thành công
      } else {
        return response.data["error"];
      }
    } catch (e) {
      return "Lỗi đăng nhập Google: ${e.toString()}";
    }
  }
}
