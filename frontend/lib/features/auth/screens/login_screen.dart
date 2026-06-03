import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_card_scaffold.dart';
import '../widgets/auth_terms_text.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/or_divider.dart';
import '../widgets/pitstop_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_auth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    ref.listenManual(authNotifierProvider, (_, next) {
      if (!mounted) return;
      final authState = next.valueOrNull;
      if (authState is AuthStateAuthenticated) {
        if (authState.user.isNewUser) {
          context.go('/personalize');
        } else {
          context.go('/home');
        }
      }
    });
  }

  void _onLogin() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    ref.read(authNotifierProvider.notifier).loginWithEmail(
          email: values['email'] as String,
          password: values['password'] as String,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMessage = switch (authState.valueOrNull) {
      AuthStateError(:final message) => message,
      _ => null,
    };

    return AuthCardScaffold(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: PitStopLogo()),
            const SizedBox(height: 20),
            const Text(
              'Chào mừng quay lại!',
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
              'Nhập email để tiếp tục',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              name: 'email',
              hintText: 'email@domain.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Vui lòng nhập email',
                ),
                FormBuilderValidators.email(errorText: 'Email không hợp lệ'),
              ]),
            ),
            const SizedBox(height: 10),
            AuthTextField(
              name: 'password',
              hintText: 'Mật khẩu',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: FormBuilderValidators.required(
                errorText: 'Vui lòng nhập mật khẩu',
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFFCA3131),
                ),
              ),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Đăng nhập',
              isLoading: isLoading,
              onPressed: isLoading ? null : _onLogin,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.push('/forgot-password'),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
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
            _RegisterLink(),
          ],
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/auth'),
          child: const Text(
            'Đăng ký',
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
