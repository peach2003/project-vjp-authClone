import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
