import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../widget/company_app_bar.dart';
import '../widget/company_header.dart';
import '../widget/section_title.dart';
import '../widget/company_introduction.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  CompanyDetailScreen({required this.company});

  @override
  _CompanyDetailScreenState createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CompanyAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CompanyHeader(company: widget.company),
            SizedBox(height: 40),
            const SectionTitle(),
            SizedBox(height: 10),
            CompanyIntroduction(introduction: widget.company.introduction),
          ],
        ),
      ),
    );
  }
}
