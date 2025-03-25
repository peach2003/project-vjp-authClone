import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://vjp-connect.com/_next/static/media/vjp-connect-banner-sm.eed45626.webp',
      width: double.infinity,
      fit: BoxFit.cover,
      height: 200,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: Center(child: Text("Không tìm thấy ảnh banner")),
        );
      },
    );
  }
}
