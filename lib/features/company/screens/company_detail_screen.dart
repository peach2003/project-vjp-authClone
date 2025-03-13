import 'package:flutter/material.dart';
import '../../company/models/company_model.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;

  CompanyDetailScreen({required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Năm Thành Lập: ${company.established}"),
            Text("Nhân Viên: ${company.employees}"),
            Text("Vốn: ${company.capital}"),
            Text("Địa Chỉ: ${company.address}"),
            Text("Ngành: ${company.category}"),
            Text("Nhu Cầu: ${company.needs}"),
            Text("Quốc Gia: ${company.country}"),
            SizedBox(height: 20),
            Image.network(
              company.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business,
                size: 80,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}