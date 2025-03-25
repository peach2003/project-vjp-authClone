import 'package:flutter/material.dart';

class CompanyIntroduction extends StatefulWidget {
  final String introduction;

  const CompanyIntroduction({Key? key, required this.introduction})
    : super(key: key);

  @override
  _CompanyIntroductionState createState() => _CompanyIntroductionState();
}

class _CompanyIntroductionState extends State<CompanyIntroduction> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _isExpanded
                ? widget.introduction
                : _getTruncatedText(widget.introduction),
            style: TextStyle(fontSize: 17, height: 2, color: Colors.black),
          ),
          SizedBox(height: 10),
          if (widget.introduction.length >
              _getTruncatedText(widget.introduction).length)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTruncatedText(String text) {
    // Giả sử mỗi dòng có khoảng 50 ký tự, bạn có thể điều chỉnh theo nhu cầu
    int maxLines = 10;
    int maxLength = maxLines * 50;
    return text.length > maxLength
        ? text.substring(0, maxLength) + '...'
        : text;
  }
}
