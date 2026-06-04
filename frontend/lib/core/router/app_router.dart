import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/providers/auth_notifier.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/auth_entry_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_map_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref, bool autoAdvanceSplash) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            SplashScreen(autoAdvance: autoAdvanceSplash),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingMapScreen(
          onFinished: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(SplashScreen.hasSeenOnboardingKey, true);
            if (context.mounted) {
              context.go('/auth');
            }
          },
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthEntryScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) {
          final email = state.extra as String;
          return SignUpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/personalize',
        builder: (context, state) => const _PlaceholderScreen('Personalize'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _PlaceholderScreen('Home'),
      ),
    ],
  );
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authValue = _ref.read(authNotifierProvider);
    if (authValue.isLoading || authValue.hasError) return null;

    final isAuthenticated = authValue.valueOrNull is AuthStateAuthenticated;
    final loc = state.matchedLocation;

    final isOnAuthRoute = loc == '/auth' ||
        loc.startsWith('/auth/') ||
        loc == '/login' ||
        loc == '/forgot-password';

    if (isAuthenticated && isOnAuthRoute) return '/home';
    if (!isAuthenticated && (loc == '/home' || loc == '/personalize')) {
      return '/auth';
    }
    return null;
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 18),
        ),
      ),
    );
  }
}
