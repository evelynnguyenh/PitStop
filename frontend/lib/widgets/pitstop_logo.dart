import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PitStopLogo extends StatelessWidget {
  const PitStopLogo({
    super.key,
    this.size = 42,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'HoltwoodOneSC',
          fontSize: size,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        children: const [
          TextSpan(
            text: 'Pit',
            style: TextStyle(color: AppColors.primary),
          ),
          TextSpan(
            text: 'Stop',
            style: TextStyle(color: AppColors.red),
          ),
        ],
      ),
    );
  }
}