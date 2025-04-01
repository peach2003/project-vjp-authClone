import 'package:flutter/material.dart';

class GroupNameField extends StatelessWidget {
  final TextEditingController controller;

  const GroupNameField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Tên nhóm",
        hintText: "Nhập tên nhóm...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.group),
      ),
    );
  }
}
