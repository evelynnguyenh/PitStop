import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const PitStopApp());
}

class PitStopApp extends StatelessWidget {
  const PitStopApp({super.key, this.enableSplashTransition = true});

  final bool enableSplashTransition;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _PitStopAppInner(enableSplashTransition: enableSplashTransition),
    );
  }
}

class _PitStopAppInner extends ConsumerWidget {
  const _PitStopAppInner({required this.enableSplashTransition});

  final bool enableSplashTransition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider(enableSplashTransition));
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
      ),
      routerConfig: router,
    );
  }
}
