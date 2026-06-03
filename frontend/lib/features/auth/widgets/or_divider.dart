import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'hoặc',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }
}
