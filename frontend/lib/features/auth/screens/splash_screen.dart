import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.autoAdvance = true});

  static const referenceSize = Size(378, 819);
  static const transitionDelay = Duration(seconds: 2);

  final bool autoAdvance;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.autoAdvance) {
      return;
    }

    Future<void>.delayed(SplashScreen.transitionDelay, () {
      if (!mounted) {
        return;
      }

      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            size: SplashScreen.referenceSize,
            child: Stack(
              children: [
                Positioned(
                  top: 232,
                  left: 92,
                  width: 194,
                  height: 268,
                  child: Image.asset(
                    'assets/images/traffic_light.png',
                    key: const Key('traffic-light'),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 526,
                  width: SplashScreen.referenceSize.width,
                  child: Transform.rotate(
                    key: const Key('pitstop-title-rotation'),
                    angle: -6 * pi / 180,
                    child: RichText(
                      key: const Key('pitstop-title'),
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Pit',
                            style: TextStyle(
                              fontFamily: 'HoltwoodOneSC',
                              fontSize: 60,
                              color: AppColors.primary,
                              shadows: [
                                Shadow(
                                  color: Color(0x40000000),
                                  offset: Offset(0, 7),
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                          ),
                          TextSpan(
                            text: 'Stop',
                            style: TextStyle(
                              fontFamily: 'HoltwoodOneSC',
                              fontSize: 60,
                              color: AppColors.red,
                              shadows: [
                                Shadow(
                                  color: Color(0x40000000),
                                  offset: Offset(0, 7),
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
