import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PitStopLogo extends StatelessWidget {
  const PitStopLogo({super.key, this.fontSize = 45.0});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'PIT',
            style: TextStyle(
              fontFamily: 'HoltwoodOneSC',
              fontSize: fontSize,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: 'STOP',
            style: TextStyle(
              fontFamily: 'HoltwoodOneSC',
              fontSize: fontSize,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
