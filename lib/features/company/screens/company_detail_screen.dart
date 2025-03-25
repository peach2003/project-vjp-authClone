import 'package:flutter/material.dart';
import '../../company/models/company_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  CompanyDetailScreen({required this.company});

  @override
  _CompanyDetailScreenState createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://vjp-connect.com/images/background2.jpg",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        widget.company.imageUrl,
                        fit: BoxFit.cover,
                        height: 150,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.business,
                              size: 80,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.company.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow(
                      "Năm Thành Lập: ",
                      widget.company.established.toString(),
                    ),
                    _buildDetailRow(
                      "Nhân Viên: ",
                      widget.company.employees.toString(),
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow(
                      "Vốn Doanh Nghiệp: ",
                      widget.company.capital,
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.company.address,
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow("Nhu Cầu: ", widget.company.needs),
                    SizedBox(height: 10),
                    if (widget.company.country == "Vietnam") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(
                            "https://vjp-connect.com/images/logo1.png",
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
                            "https://vjp-connect.com/images/logo2.png",
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
                      ),
                      SizedBox(height: 10),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(
                            "https://vjp-connect.com/images/logo1.png",
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
                            "https://vjp-connect.com/images/logo4.png",
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
                      ),
                    ],
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                size: 24,
                                color: Colors.grey,
                              ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.company.group,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Column(
              children: [
                Text(
                  "LỜI GIỚI THIỆU",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.blue,
                        thickness: 1,
                        endIndent: 20,
                        indent: 20,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "GIỚI THIỆU SƠ LƯỢC VỀ",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                        Text(
                          "CÔNG TY",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.blue,
                        thickness: 1,
                        endIndent: 20,
                        indent: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded
                        ? widget.company.introduction
                        : _getTruncatedText(widget.company.introduction),
                    style: TextStyle(
                      fontSize: 17,
                      height: 2,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (widget.company.introduction.length >
                      _getTruncatedText(widget.company.introduction).length)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 17,
                height: 1.5,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.black, fontSize: 17, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _getTruncatedText(String text) {
    // Giả sử mỗi dòng có khoảng 50 ký tự, bạn có thể điều chỉnh theo nhu cầu
    int maxLines = 10;
    int maxLength = maxLines * 50;
    return text.length > maxLength
        ? text.substring(0, maxLength) + '...'
        : text;
  }
}
