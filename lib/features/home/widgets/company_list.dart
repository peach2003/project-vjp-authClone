import 'package:flutter/material.dart';
import '../../company/screens/company_detail_screen.dart';
import '../../company/models/company_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      introduction: ''' 
  Công ty VIET JAPAN PARTNER được thành lập từ tháng 10/2018 là công ty đại diện cho VIET JAPAN PARTNER Group (VJP Group) hoạt động trên 3 lĩnh vực chính: Phát triển nguồn lực, Công nghệ thông tin và Hỗ trợ giao thương Việt-Nhật. VJP Group hiện có 25 nhân sự với trụ sở chính ở Tp.HCM và VPĐD ở thủ đô Hà Nội, thành phố Đà Nẵng, tỉnh An Giang. Khách hàng của VJP Group là các công ty ở Nhật Bản, các công ty Nhật ở Việt Nam và các công ty Việt Nam có phát triển kinh doanh cho thị trường Nhật.
VJP Group định hướng phát triển thành hệ sinh thái dịch vụ hỗ trợ các doanh nghiệp Nhật Bản và Việt Nam trong hoạt động phát triển kinh doanh liên quan giữa 2 quốc gia.
VJP Group cung cấp dịch vụ theo mô hình One Stop Service (Dịch vụ một cổng) dựa trên nền tảng là sự kết hợp giữa 3 yếu tố chính:
- Kiến thức chuyên môn và kinh nghiệm từ các chuyên gia Nhật Bản, Việt Nam
- Hệ thống mạng lưới đối tác trên nhiều lĩnh vực
- Sức mạnh công nghệ
nhằm mang đến hỗ trợ tốt nhất, hiệu quả nhất cho các doanh nghiệp khi phát triển kinh doanh ở quốc gia đối tác.
VJP Group được sáng lập và điều hành bởi Founder Võ Đức Thắng, người có quá trình làm việc và học tập tại Nhật Bản hơn 10 năm, tốt nghiệp thạc sĩ CNTT tại học viện Công nghiệp (Tokyo). Ngoài ra, còn có các cộng sự hỗ trợ là các chuyên gia Nhật Bản, Việt Nam và các nhân sự trẻ nhiệt huyết.
Công ty Viet Japan Partner đóng vai trò cốt lõi trong hành trình xây dựng hệ sinh thái dịch vụ này và thông qua việc đó thực hiện sứ mệnh đào tạo, phát triển nguồn nhân lực số cho xã hội như tầm nhìn đã đề ra.
+ Tầm nhìn của công ty Viet Japan Partner đến 2030:
Trở thành doanh nghiệp đào tạo, cung ứng nhân lực số chuẩn Nhật Bản hàng đầu Việt Nam và Đông Nam Á với tổng số lượng cung ứng 10,000 người.
+ Sứ mệnh của công ty Viet Japan Partner:
Thông qua Đào tạo - Huấn luyện thực chiến cho sinh viên theo chuẩn Nhật Bản kết hợp với cung cấp dịch vụ hỗ trợ có giá trị cho Doanh nghiệp góp phần vào sự phát triển của nền kinh tế số.
+ Giá trị cốt lõi: 3CTH
  Chủ động - Cam kết - Chuyên nghiệp
  Trung thực - Trách nhiệm - Tích cực
  Học hành - Hiệu quả - Hạnh phúc
Nếu bạn đang tìm kiếm đối tác đồng hành hỗ trợ cho việc kinh doanh Việt Nam - Nhật Bản, hãy liên hệ ngay với chúng tôi để được tư vấn nhé!''',
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
      introduction:
          '''Vào những năm 1986 - 1990, với việc tập trung vào nền kinh tế thị trường, tạo điều kiện cho các doanh nghiệp phát triển, nền kinh tế Việt Nam thật sự đã tạo được những chuyển biến mạnh mẽ.

Thấy được cơ hội từ những sự chuyển mình mạnh mẽ của nền kinh tế cộng sự am hiểu về thị trường, đặc biệt trong ngành phụ liệu da giày, vào năm 1990, ông Đoàn Ngọc Hải quyết định Thành lập công ty TNHH Nhựa Thương Mại Liên Đoàn, tiền thân của Công Ty Đầu Tư và Phát Triển Leedo ngày nay, chuyên cung cấp nguyên liệu simili và các loại đế PU.

Sau hơn 30 năm hình thành và phát triển, từ 1 nhà máy nhỏ tại Bình Chánh với 1 dây chuyền sản xuất cơ bản, đến nay Công Ty Đầu Tư và Phát Triển Leedo đã mở rộng cả về mô hình sản xuất cũng như các loại hình dịch vụ cung cấp. Tính đến năm 2017:

300 nhân viên 
2 nhà xưởng chính: Long An (45,000m2) và Bình Chánh (6,00m2) với dây chuyền sản xuất khép kín
Công nghệ sử dụng: Công nghệ khuôn CNC, công nghệ sản xuất EVA, dây chuyền sản xuất PU và direct PU
Sản phẩm/ dịch vụ cung cấp: Các loại đế, dép thành phẩm và cho thuê nhà xưởng với mục tiêu tạo ra và cung cấp các sản phẩm đế có chất lương tốt cùng với mức giá phù hợp, đáp ứng đúng với sức tiêu dùng của khách hàng. Công ty Đầu Tư và Phát triển Leedo, phần nào cũng đã để lại dấu ấn trên thị trường cung ứng phụ liệu về da giày:

Top 5 nhà cung ứng PU tại Việt Nam
Chiếm 40% thị phần đế PU tại Hồ Chí Minh 
4.000.000 sản phẩm/ năm
Trải qua hơn 30 năm hoạt động, công ty đã từng bước xây dựng được thương hiệu uy tín trong ngành sản xuất cho thị trường trong nước lẫn quốc tế và được nhiều thương hiệu lựa chọn như Biti's, Tuấn Việt, Hồng Anh, Hồng Thạnh, Superga etc. Hiện công ty đang mở rộng thêm mảng giày dép nhựa thành phẩm và túi nhằm phục vụ cho khách hàng nội địa.''',
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
      introduction:
          '''Gia Trịnh, thương hiệu bánh cổ truyền ra đời từ năm 2006, gắn liền với giá trị cốt lõi: Dược thiện, Từ tâm, Bảo tồn và Đổi mới.

Với sứ mệnh lưu giữ tinh hoa ẩm thực Việt, Gia Trịnh mang đến những chiếc bánh không chỉ đậm chất truyền thống mà còn đảm bảo chất lượng vượt trội.

Nguyên liệu tự nhiên hoàn toàn từ cây cỏ, hoa lá, không chất phụ gia, hạn chế bảo quản, giúp thực khách trải nghiệm hương vị thuần khiết, tinh tế với chi phí hợp lý, gần gũi và an toàn.''',
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
      introduction:
          '''Chúng tôi, đội ngũ nhân sự có nhiều năm kinh nghiệm làm việc trong lĩnh vực kế toán – kiểm toán, tư vấn thuế của các Công ty kiểm toán. Chúng tôi thấu hiểu sâu sắc những khó khăn, vướng mắc, cũng như các lỗi vô tình dẫn đến sai phạm trong quản trị tài chính, tổ chức bộ máy kế toán, lập các báo cáo thuế… mà các tổ chức và doanh nghiệp phải đối mặt trong suốt quá trình hình thành, phát triển, và cả trong giai đoạn giải thể.

Chúng tôi sẵn sàng cung cấp cho các bạn các dịch vụ tư vấn chuyên sâu để giúp các bạn hoàn thiện công tác Quản trị tài chính, Xây dựng bộ máy tổ chức kế toán hiệu quả, hạn chế các rủi ro về thuế.

Công ty TNHH Tư vấn thuế và Giải pháp quản trị TH.FINTAX (TH.Fintax) được thành lập theo Giấy chứng nhận số 0108695808 do Sở Kế hoạch và đầu tư TP Hà Nội cấp ngày 12 tháng 4 năm 2019. TH.FINTAX được Tổng Cục Thuế chấp nhận hành nghề dịch vụ đại lý thuế theo Công văn số 26969/XNDLT-CTHN ngày 13/07/2021
Văn phòng giao dịch: Tầng 12 Toà Licogi 13, số 164 Khuất Duy Tiến, Quận Thanh Xuân, Hà Nội''',
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
      introduction:
          '''Kể từ khi thành lập, Công ty TNHH Nakayama Shoji đã tham gia bán buôn và bán lẻ trong lĩnh vực nhiên liệu gia dụng và công nghiệp, thiết bị hệ thống ống nước và thiết bị nhà ở, đồng thời nỗ lực phát triển cộng đồng địa phương. Ước muốn làm phong muốn cho địa phương của người sáng lập, Noboru Nakayama, đã được lưu truyền cho đến ngày nay. Ngoài ra, chúng tôi đang thúc đẩy sự hấp dẫn của vùng Tango thông qua hoạt động kinh doanh thực phẩm rất phù hợp với các hoạt động kinh doanh hệ thống ống nước và nguồn nhiệt của chúng tôi.

Điểm mạnh của công ty chúng tôi là chúng tôi duy trì một kho vật liệu liên tục được sử dụng trong các công trình cấp nước và khí đốt, đồng thời duy trì một hệ thống có thể ứng phó với các trường hợp khẩn cấp.

Chúng tôi sẽ tiếp tục lắng nghe phản hồi của khách hàng và giúp họ có một cuộc sống thoải mái và trọn vẹn. Và trong một thời đại thay đổi nhanh chóng, chúng tôi sẽ trở thành một tổ chức mà chính chúng tôi sẽ thay đổi cùng với nó.

Xin hãy kỳ vọng vào Nakayama Shoji.''',
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
      introduction:
          '''Công ty Thương mại Fujino Shoji đang triển khai tám lĩnh vực kinh doanh khác nhau. Đó là dịch vụ xăng dầu và bảo trì ô tô, ô tô đã qua sử dụng, công nghệ thông tin và truyền thông, điện thoại di động, bảo hiểm, và sản xuất thực phẩm lên men. Chúng tôi cung cấp các dịch vụ trực tiếp liên quan đến cuộc sống để hỗ trợ khách hàng trong việc có một cuộc sống "an toàn, an tâm và thoải mái".''',
    ), // Thêm các công ty khác tương tự
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
                      "Năm Thành Lập: ",
                      company.established.toString(),
                    ),
                    _buildDetailRow(
                      "Nhân Viên: ",
                      company.employees.toString(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        if (company.country == 'Vietnam') ...[
                          Image.network(
                            'https://vjp-connect.com/_next/static/media/logo1.3907871c.png',
                            width: 60,
                            height: 50,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                          ),
                          SizedBox(width: 8),
                          Image.network(
                            'https://vjp-connect.com/_next/static/media/ctyvna.67f6a5a0.png',
                            width: 60,
                            height: 50,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                          ),
                        ] else ...[
                          Image.network(
                            'https://vjp-connect.com/_next/static/media/logo1.3907871c.png',
                            width: 60,
                            height: 50,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                          ),
                          SizedBox(width: 8),
                          Image.network(
                            'https://vjp-connect.com/_next/static/media/ctynhat.f204ff5d.png',
                            width: 60,
                            height: 50,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.network(
                              "https://vjp-connect.com/_next/static/media/Icon_Group.e6df7480.svg",
                              width: 50,
                              height: 50,
                              color: const Color.fromARGB(255, 227, 212, 1),
                              colorBlendMode: BlendMode.srcIn,
                              placeholderBuilder:
                                  (context) => Icon(
                                    Icons.error,
                                    size: 10,
                                    color: Colors.grey,
                                  ),
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
                fontSize: 17,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
