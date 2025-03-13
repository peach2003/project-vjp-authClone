import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ExpertCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> experts = [
    {
      "name": "Fushimi Kiyoshi",
      "avatar":
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/expert-team-01.jpg",
      "specialties": ["Tư vấn kinh doanh", "Bằng sáng chế"],
      "education": [
        {
          "degree": "Thạc sĩ Công nghệ Sáng Tạo",
          "institution": "Đại học Kỹ thuật Công nghiệp",
          "field": "Kỹ thuật Sáng tạo",
          "location": "Tokyo, Japan",
        },
        {
          "degree": "Bằng Thạc sĩ (học thuật)",
          "institution": "Đại học Từ Xa",
          "field": "Nghiên cứu Thông tin",
        },
        {
          "degree": "Cử nhân Kỹ thuật",
          "institution": "Đại học Keio",
          "field": "Cơ khí, Khoa học và Công nghệ",
        },
        {
          "degree": "Cử nhân Luật",
          "institution": "Đại học Keio",
          "field": "Luật",
        },
      ],
      "consulting_fee": "Tư vấn miễn phí giờ đầu tiên",
      "experience": [
        "Chuyên gia Tư vấn kinh doanh, Nhà phân tích sở hữu trí tuệ (Bằng sáng chế)",
        "Giảng viên thỉnh giảng, Đại học Kỹ thuật Công nghiệp",
        "Cố vấn Kỹ thuật, Văn phòng công ty Luật sư Bằng sáng chế quốc tế iRify",
        "Cố vấn sở hữu trí tuệ của công ty liên doanh khác",
      ],
    },
    {
      "name": "Inoue Tadasu",
      "avatar":
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/itcomtor.png",
      "specialties": ["Tư vấn Web"],
      "education": [
        {
          "degree": "Thạc sĩ Công nghệ Sáng Tạo",
          "institution": "Đại học Kỹ thuật Công nghiệp",
          "field": "Kỹ thuật Sáng tạo",
          "location": "Tokyo, Japan",
        },
        {
          "degree": "Tốt nghiệp Đại học Thành phố Yokohama",
          "institution": "Đại học Thành phố Yokohama",
        },
      ],
      "experience": [
        "Giám đốc công ty Tokyo Literacy Co., Ltd.",
        "Hơn 60 khách hàng làm việc trực tiếp và sản xuất nội dung cho hơn 800 công ty",
        "Cung cấp các dịch vụ SEM, web branding, video web, marketing SNS, UX design",
      ],
    },
    {
      "name": "Võ Đức Thắng",
      "avatar":
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/thangvo.png",
      "specialties": ["Tư vấn kinh doanh và CNTT"],
      "education": [
        {
          "degree": "Thạc sĩ Công nghệ",
          "institution": "Đại học Kỹ thuật Công nghiệp",
          "field": "Kiến trúc Thông Tin",
        },
        {
          "degree": "Cử nhân Khoa học Máy Tính",
          "institution": "Đại học An Giang",
        },
      ],
      "experience": [
        "Chuyên viên tư vấn IT",
        "Tư vấn kinh doanh Nhật Bản – Việt Nam",
        "Giám đốc chi nhánh TP.HCM, Viện nghiên cứu đạo đức kinh doanh",
        "Phó Chủ tịch BNI WOW Chapter (2021)",
        "Chủ tịch Liên minh Kinh doanh Việt Nam – Nhật Bản (2022)",
      ],
    },
    {
      "name": "Mochizuki Ginko",
      "avatar":
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/mochi.jpg",
      "specialties": ["Tư vấn xây dựng WEB"],
      "education": [
        {
          "degree": "Thạc sĩ chuyên nghiệp",
          "institution": "Đại học Kỹ thuật Công nghiệp",
          "field": "Thiết kế Công nghiệp",
          "location": "Tokyo, Japan",
        },
      ],
      "experience": [
        "Quản lý xây dựng và vận hành trang web cho Hiệp hội An toàn và Nâng cao Kỹ năng Nhật Bản",
        "Cán bộ giáo dục vũ trụ tại Câu lạc bộ phi hành gia trẻ Nhật Bản",
        "PM của Dự án 'Life is small'",
      ],
    },
    {
      "name": "Akira Ooka",
      "avatar":
          "https://vjpconnect.s3.ap-southeast-1.amazonaws.com/z5534562674424_5b28e63ba75b72c9a18e5230a596e4e7.jpg",
      "specialties": ["Tư vấn tối ưu hóa quy trình sản xuất và kinh doanh"],
      "education": [
        {
          "degree": "Thạc sĩ Công nghệ Sáng tạo",
          "institution": "Đại học Khoa học và Công nghệ Công nghiệp",
        },
        {
          "degree": "Kỹ sư IE/IEr",
          "institution": "Đại học Quản lý Công nghiệp",
        },
      ],
      "experience": [
        "Nghiên cứu viên tại Công ty Spiralmind, Ltd",
        "Leader /Meister tại Công ty Broadleaf, Ltd",
        "Senior Evangelist/Meister tại Công ty Broadleaf, Ltd",
        "Giám đốc tại Viện Đổi mới Công nghiệp",
      ],
    },
    {
      "name": "Lương Thị Hương",
      "avatar":
          "https://vjpconnect.s3.ap-southeast-1.amazonaws.com/Screenshot%202024-05-08%20104124.png",
      "specialties": ["Đào tạo nhân sự", "Tư vấn tâm lý"],
      "education": [
        {
          "degree": "Cử nhân Ngôn ngữ Nhật Bản",
          "institution": "Đại học Ngoại ngữ, Đại học Quốc Gia Hà Nội",
        },
        {
          "degree": "NLP Train The Trainer",
          "institution": "Hiệp hội ABNLP Hoa Kỳ",
        },
        {"degree": "Chuyên gia trị liệu Dòng thời gian"},
      ],
      "experience": [
        "Tư vấn và trị liệu tâm lý",
        "Đào tạo doanh nghiệp",
        "Lead Auditor ISO9001",
        "Chứng chỉ CEO tại trường Doanh nhân PTI",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400.0,
        autoPlay: true,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items:
          experts.map((expert) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(expert['avatar']),
                          radius: 60,
                          
                        ),
                        SizedBox(height: 15),
                        Text(
                          expert['name'],
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          expert['specialties'].join(', '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: const Color.fromARGB(255, 8, 8, 8),
                          ),
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'Xem Hồ Sơ',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              252,
                              59,
                              59,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}
