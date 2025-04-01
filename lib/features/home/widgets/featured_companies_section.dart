import 'package:flutter/material.dart';
import 'company_list.dart';

class FeaturedCompaniesSection extends StatelessWidget {
  const FeaturedCompaniesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "NHỮNG CÔNG TY NỔI BẬT",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Padding(padding: const EdgeInsets.all(16.0), child: CompanyList()),
      ],
    );
  }
}
