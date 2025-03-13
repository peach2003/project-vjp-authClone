import 'package:flutter/material.dart';
import '../../company/screens/company_detail_screen.dart';
import '../../company/models/company_model.dart';

class CompanyList extends StatelessWidget {
  final List<Company> companies = [
    Company(
      name: "CÔNG TY TNHH ĐỒNG HÀNH VIỆT JAPAN",
      established: 2018,
      employees: 25,
      capital: "2.000.000.000 VNĐ",
      address:
          "Phòng 22, Nhà 8, Khu Công nghệ Phần mềm Quang Trung, Quận 12, TP.HCM, Việt Nam",
      category: "Tư vấn tuyển dụng, giới thiệu việc làm",
      needs:
          "Tìm kiếm công ty Nhật muốn sử dụng nguồn nhân lực IT của Việt Nam/ Công ty Nhật muốn đầu tư, phát triển kinh doanh ở Việt Nam/ công ty muốn phát triển giao thương giữa Việt Nam và Nhật Bản",
      country: "Vietnam",
      imageUrl:
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/32eeeef2334c618cee14df81359d6913",
      group: "BNI",
    ),
    Company(
      name: "CÔNG TY TNHH NHỰA THƯƠNG MẠI LIÊN ĐOÀN",
      established: 1990,
      employees: 300,
      capital: "9.000.000.000 VND",
      address: "185 Trần Quý, Phường 4, Quận 11, Tp. Hồ Chí Minh, Việt Nam.",
      category: "Sản xuất nhựa",
      needs:
          "Tìm kiếm các khách hàng nhà bán lẻ, nhà phân phối giày dép tại Nhật Bản, quảng bá giới thiệu các sản phẩm giày dép nhựa và giày vải tiện dụng đến người tiêu dùng trực tiếp",
      country: "Vietnam",
      imageUrl:
          "https://vjpconnect.s3.ap-southeast-1.amazonaws.com/252/950c4fbfb8407750950fc1bdb40e7bec",
      group: "VCCI",
    ),
    Company(
      name: "CÔNG TY CỔ PHẦN GIA TRỊNH BAKERY",
      established: 2006,
      employees: 100,
      capital: "9.000.000.000 VNĐ",
      address:
          "Số 16A Lý Nam Đế, phường Hàng Mã, Quận Hoàn Kiếm, Thành phố Hà Nội, Việt Nam",
      category: "Thực phẩm và đồ uống",
      needs:
          "Tìm các công ty cần giải pháp về ẩm thực, quà tặng mang đậm nét truyền thống Việt Nam, chất lượng cao.",
      country: "Vietnam",
      imageUrl:
          "https://vjpconnect.s3.ap-southeast-1.amazonaws.com/vjp-connect/profile/318/company/20241118103102_tải xuống (7).png",
      group: "BNI",
    ),
    Company(
      name: "Công ty TNHH Tư vấn thuế và Giải pháp quản trị TH.Fintax",
      established: 2019,
      employees: 10,
      capital: "2.000.000.000 VND",
      address: "198 Thượng Đình, Phường Thượng Đình, Quận Thanh Xuân, Hà Nội",
      category: "Pháp lý và Kế toán",
      needs:
          "Tìm các công ty muốn thành lập pháp nhân Việt Nam, các công ty cần hỗ trợ dịch vụ báo cáo thuế, kế toán",
      country: "Vietnam",
      imageUrl:
          "https://vjpconnect.s3.ap-southeast-1.amazonaws.com/logo_final-02.png",
      group: "VCCI",
    ),
    Company(
      name: "NAKAYAMA CO., LTD",
      established: 1948,
      employees: 57,
      capital: "20.000.000 JPY",
      address:
          "657-1 Sugitani, Mineyama-cho, thành phố Kyotango, tỉnh Kyoto, Nhật Bản.",
      category: "Sản xuất và gia công cơ khí",
      needs: "Tìm đối tác Việt Nam để hợp tác sản xuất và cung cấp nguyên liệu",
      country: "Japan",
      imageUrl:
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/50d945a1c2196cca66dd7706e599f1af",
      group: "Keidanren",
    ),
    Company(
      name: "FUJINO SHOJI CO.,LTD",
      established: 2023,
      employees: 90,
      capital: "25.000.000 JPY",
      address:
          "Số 11-3, phường Gokojo, thành phố Higashi-omi, tỉnh Shiga, Nhật Bản.",
      category: "Thương mại và phân phối",
      needs: "Tìm đối tác Việt Nam để nhập khẩu và phân phối sản phẩm",
      country: "Japan",
      imageUrl:
          "https://vjp-connect-upload.s3.ap-southeast-1.amazonaws.com/7d22b1a6b99de92f97e18484e73ab8bf",
      group: "Keidanren",
    ),  // Thêm các công ty khác tương tự
  ];

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách công ty theo quốc gia
    final vietnamCompanies =
        companies.where((c) => c.country == 'Vietnam').toList();
    final japanCompanies =
        companies.where((c) => c.country == 'Japan').toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.blue, thickness: 1, endIndent: 10),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "CÔNG TY ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "VIỆT NAM",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(color: Colors.blue, thickness: 1, indent: 10),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildCompanyList(vietnamCompanies),
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.blue, thickness: 1, endIndent: 10),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "CÔNG TY ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "NHẬT BẢN",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(color: Colors.blue, thickness: 1, indent: 10),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildCompanyList(japanCompanies),
        ],
      ),
    );
  }

  Widget _buildCompanyList(List<Company> companies) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://vjp-connect.com/images/background2.jpg",
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        company.imageUrl ?? "https://via.placeholder.com/80",
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.business,
                              size: 80,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        company.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      "📅 Năm Thành Lập: ",
                      company.established.toString(),
                    ),
                    _buildDetailRow(
                      "👥 Nhân Viên: ",
                      company.employees.toString(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 24,
                              color: const Color.fromARGB(255, 227, 212, 1),
                            ),

                            SizedBox(width: 5),
                            Text(
                              company.group,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CompanyDetailScreen(company: company),
                              ),
                            );
                          },
                          child: Text(
                            "Chi Tiết",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTruncated = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        maxLines: isTruncated ? 2 : null,
        overflow: isTruncated ? TextOverflow.ellipsis : TextOverflow.visible,
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(text: value, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
