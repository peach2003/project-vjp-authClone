import 'package:flutter/material.dart';

class CompanyLogos extends StatelessWidget {
  final String country;

  const CompanyLogos({Key? key, required this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.network(
          "https://vjp-connect.com/images/logo1.png",
          width: 60,
          height: 50,
          errorBuilder:
              (context, error, stackTrace) =>
                  Icon(Icons.error, size: 24, color: Colors.grey),
        ),
        SizedBox(width: 8),
        Image.network(
          country == "Vietnam"
              ? "https://vjp-connect.com/images/logo2.png"
              : "https://vjp-connect.com/images/logo4.png",
          width: 60,
          height: 50,
          errorBuilder:
              (context, error, stackTrace) =>
                  Icon(Icons.error, size: 24, color: Colors.grey),
        ),
      ],
    );
  }
}
