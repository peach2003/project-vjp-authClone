import 'package:flutter/material.dart';

class PersonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin người dùng')),
      body: Center(child: Text('Thông tin người dùng sẽ được hiển thị ở đây.')),
    );
  }
}
