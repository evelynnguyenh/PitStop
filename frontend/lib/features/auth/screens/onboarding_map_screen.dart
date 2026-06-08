import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingMapScreen extends StatefulWidget {
  const OnboardingMapScreen({super.key, this.onFinished});

  static const referenceSize = Size(378, 819);

  final VoidCallback? onFinished;

  @override
  State<OnboardingMapScreen> createState() => _OnboardingMapScreenState();
}

class _OnboardingMapScreenState extends State<OnboardingMapScreen> {
  static const _finishDelay = Duration(milliseconds: 350);

  int _visibleRows = 0;
  bool _finishing = false;

  void _handleTap() {
    if (_visibleRows < 3) {
      setState(() {
        _visibleRows += 1;
      });
      return;
    }

    _finish();
  }

  void _handleSkip() {
    if (_finishing) {
      return;
    }

    setState(() {
      _visibleRows = 3;
      _finishing = true;
    });

    Future<void>.delayed(_finishDelay, () {
      if (!mounted) {
        return;
      }

      _finish();
    });
  }

  void _finish() {
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox.fromSize(
              size: OnboardingMapScreen.referenceSize,
              child: ClipRect(
                child: Stack(
                  children: [
                    const _MapBackground(),
                    const Positioned(
                      top: 160,
                      left: 0,
                      width: 378,
                      child: _PitStopLogo(),
                    ),
                    _PinFeatureRow(
                      visible: _visibleRows >= 1,
                      top: 301,
                      left: 39,
                      text: 'Drop a review',
                      pinKeyName: 'map-pin-drop',
                      keyName: 'feature-label-drop',
                    ),
                    _PinFeatureRow(
                      visible: _visibleRows >= 2,
                      top: 424,
                      left: 135,
                      text: 'Watch it pin',
                      pinKeyName: 'map-pin-watch',
                      keyName: 'feature-label-watch',
                      pinAfterText: true,
                    ),
                    _PinFeatureRow(
                      visible: _visibleRows >= 3,
                      top: 560,
                      left: 38,
                      text: 'Roll your next stop 🎲',
                      pinKeyName: 'map-pin-roll',
                      keyName: 'feature-label-roll',
                    ),
                    Positioned(
                      right: 15,
                      bottom: 27,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleSkip,
                        child: Row(
                          key: const Key('skip-control'),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'SKIP',
                              key: Key('skip-label'),
                              style: TextStyle(
                                fontFamily: 'HoltwoodOneSC',
                                fontSize: 28,
                                color: Color(0xFF9D9D9D),
                              ),
                            ),
                            const SizedBox(width: 11),
                            SvgPicture.asset(
                              'assets/icons/skip_forward.svg',
                              key: const Key('skip-icon'),
                              width: 30,
                              height: 30,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF9D9D9D),
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -115,
          left: -223,
          width: 824,
          height: 1788,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
            child: Image.asset(
              'assets/images/background_map.png',
              key: const Key('onboarding-map-background'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            key: Key('onboarding-map-wash'),
            decoration: BoxDecoration(
              color: Color(0xB8F5F5F5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PitStopLogo extends StatelessWidget {
  const _PitStopLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      key: const Key('onboarding-pitstop-logo'),
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'PIT',
            style: TextStyle(
              fontFamily: 'HoltwoodOneSC',
              fontSize: 45,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: 'STOP',
            style: TextStyle(
              fontFamily: 'HoltwoodOneSC',
              fontSize: 45,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinFeatureRow extends StatelessWidget {
  const _PinFeatureRow({
    required this.visible,
    required this.top,
    required this.left,
    required this.text,
    required this.pinKeyName,
    required this.keyName,
    this.pinAfterText = false,
  });

  static const _animationDuration = Duration(milliseconds: 460);
  static const _slideDistance = 18.0;

  final bool visible;
  final double top;
  final double left;
  final String text;
  final String pinKeyName;
  final String keyName;
  final bool pinAfterText;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final pin = SvgPicture.asset(
      'assets/icons/map_pin.svg',
      key: Key(pinKeyName),
      width: 45,
      height: 45,
      colorFilter: const ColorFilter.mode(
        Color(0xFF242424),
        BlendMode.srcIn,
      ),
    );
    final label = Text(
      text,
      key: Key(keyName),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF050505),
      ),
    );

    return Positioned(
      top: top,
      left: left,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: _animationDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final direction = pinAfterText ? 1 : -1;
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset((1 - value) * _slideDistance * direction, 0),
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: pinAfterText
              ? [label, const SizedBox(width: 9), pin]
              : [pin, const SizedBox(width: 8), label],
        ),
      ),
    );
  }
}
