import 'package:flutter/material.dart';
import '../models/company_model.dart';
import 'detail_row.dart';
import 'company_logos.dart';
import 'group_badge.dart';

class CompanyHeader extends StatelessWidget {
  final Company company;

  const CompanyHeader({Key? key, required this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://vjp-connect.com/images/background2.jpg"),
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
                company.imageUrl,
                fit: BoxFit.cover,
                height: 150,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Icon(Icons.business, size: 80, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            Text(
              company.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            DetailRow(
              label: "Năm Thành Lập: ",
              value: company.established.toString(),
            ),
            DetailRow(
              label: "Nhân Viên: ",
              value: company.employees.toString(),
            ),
            SizedBox(height: 10),
            DetailRow(label: "Vốn Doanh Nghiệp: ", value: company.capital),
            SizedBox(height: 10),
            Text(company.address, style: TextStyle(fontSize: 17)),
            SizedBox(height: 10),
            DetailRow(label: "Nhu Cầu: ", value: company.needs),
            SizedBox(height: 10),
            CompanyLogos(country: company.country),
            SizedBox(height: 10),
            GroupBadge(group: company.group),
          ],
        ),
      ),
    );
  }
}
