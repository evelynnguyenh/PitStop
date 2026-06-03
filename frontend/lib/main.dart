import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/screens/splash_screen.dart';

void main() {
  runApp(const PitStopApp());
}

class PitStopApp extends StatelessWidget {
  const PitStopApp({super.key, this.enableSplashTransition = true});

  final bool enableSplashTransition;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
      ),
      home: SplashScreen(autoAdvance: enableSplashTransition),
    );
  }
}
