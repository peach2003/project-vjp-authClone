import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';
import '../widgets/company_list.dart';
import '../widgets/language_selector.dart';
import '../widgets/expert_carousel.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 AppBar chỉ chứa LanguageSelector căn phải
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 215, 64),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 60,
              fit: BoxFit.cover,
            ),
            LanguageSelector(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Banner chính (hiển thị dưới Logo + Nút Đăng Nhập)
            Image.network(
              'https://vjp-connect.com/_next/static/media/vjp-connect-banner-sm.eed45626.webp',
              width: double.infinity,
              fit: BoxFit.cover,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text("Không tìm thấy ảnh banner")),
                );
              },
            ),

            SizedBox(height: 20),

            // 🔹 Chọn quốc gia
            BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text("🇻🇳 Việt Nam", style: TextStyle(fontSize: 18)),
                      selected: state.languageCode == "VN",
                      onSelected: (selected) {
                        context.read<LanguageBloc>().add(ChangeLanguage("VN"));
                      },
                    ),
                    SizedBox(width: 10),
                    ChoiceChip(
                      label: Text("🇯🇵 Nhật Bản", style: TextStyle(fontSize: 18)),
                      selected: state.languageCode == "JP",
                      onSelected: (selected) {
                        context.read<LanguageBloc>().add(ChangeLanguage("JP"));
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),

            // 🔹 Nút "Tìm doanh nghiệp"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                print("Tìm doanh nghiệp!");
              },
              child: Text(
                "Tìm doanh nghiệp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 Tiêu đề "NHỮNG CÔNG TY NỔI BẬT"
            Text(
              "NHỮNG CÔNG TY NỔI BẬT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10),

            // 🔹 Danh sách công ty nổi bật
            Padding(padding: const EdgeInsets.all(16.0), child: CompanyList()),

            SizedBox(height: 10),

            // 🔹 Tiêu đề "CÁC CHUYÊN GIA HỖ TRỢ"
            Text(
              "CÁC CHUYÊN GIA HỖ TRỢ",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),

            // 🔹 Tiêu đề "CHUYÊN GIA ĐẠI DIỆN"
            Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.blue, thickness: 1, indent: 70),
              ),
              SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "CHUYÊN GIA ĐẠI DIỆN",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Divider(color: Colors.blue, thickness: 1, endIndent: 70),
              ),
            ],
          ),

            SizedBox(height: 10),
            ExpertCarousel(),
          ],
        ),
      ),
    );
  }
}
