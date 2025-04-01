import 'package:flutter/material.dart';
import 'expert_carousel.dart';

class ExpertSection extends StatelessWidget {
  const ExpertSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "CÁC CHUYÊN GIA HỖ TRỢ",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        _buildExpertTitle(),
        SizedBox(height: 10),
        ExpertCarousel(),
      ],
    );
  }

  Widget _buildExpertTitle() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.blue, thickness: 1, indent: 70)),
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
    );
  }
}
