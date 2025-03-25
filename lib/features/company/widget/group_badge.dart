import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupBadge extends StatelessWidget {
  final String group;

  const GroupBadge({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.network(
          "https://vjp-connect.com/_next/static/media/Icon_Group.e6df7480.svg",
          width: 50,
          height: 50,
          color: const Color.fromARGB(255, 227, 212, 1),
          colorBlendMode: BlendMode.srcIn,
          placeholderBuilder:
              (context) => Icon(Icons.error, size: 24, color: Colors.grey),
        ),
        SizedBox(width: 8),
        Text(
          group,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
