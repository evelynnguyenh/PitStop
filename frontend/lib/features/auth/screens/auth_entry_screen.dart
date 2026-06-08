import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_card_scaffold.dart';
import '../widgets/auth_terms_text.dart';
import '../widgets/or_divider.dart';
import '../widgets/pitstop_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_auth_button.dart';

class AuthEntryScreen extends ConsumerStatefulWidget {
  const AuthEntryScreen({super.key});

  @override
  ConsumerState<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends ConsumerState<AuthEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authNotifierProvider.notifier).clearError(),
    );
    ref.listenManual(authNotifierProvider, (_, next) {
      if (!mounted) return;
      final authState = next.valueOrNull;
      if (authState is AuthStateAuthenticated) {
        _navigateAfterAuth(authState);
      }
    });
  }

  void _navigateAfterAuth(AuthStateAuthenticated state) {
    if (state.user.isNewUser) {
      context.go('/personalize');
    } else {
      context.go('/home');
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      ref.read(authNotifierProvider.notifier).clearError();
      final email = _formKey.currentState!.value['email'] as String;
      context.push('/auth/signup', extra: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return AuthCardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: PitStopLogo()),
          const SizedBox(height: 20),
          const Text(
            'Tạo tài khoản',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhập email để bắt đầu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 20),
          FormBuilder(
            key: _formKey,
            child: _EmailField(enabled: !isLoading),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Tiếp tục',
            isLoading: isLoading,
            onPressed: _onContinue,
          ),
          const SizedBox(height: 16),
          const OrDivider(),
          const SizedBox(height: 12),
          SocialAuthButton(
            label: 'Tiếp tục với Google',
            iconAsset: 'assets/icons/google.svg',
            isLoading: isLoading,
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signInWithGoogle(),
          ),
          const SizedBox(height: 10),
          SocialAuthButton(
            label: 'Tiếp tục với Apple',
            iconAsset: 'assets/icons/apple.svg',
            isLoading: isLoading,
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signInWithApple(),
          ),
          const SizedBox(height: 12),
          const AuthTermsText(),
          const Spacer(),
          _LoginLink(),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'email',
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Vui lòng nhập email'),
        FormBuilderValidators.email(errorText: 'Email không hợp lệ'),
      ]),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: 'email@domain.com',
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: Color(0xFFAAAAAA),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD65A)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCA3131)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCA3131)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
        GestureDetector(
          onTap: () {
            final container = ProviderScope.containerOf(context);
            container.read(authNotifierProvider.notifier).clearError();
            context.go('/login');
          },
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
