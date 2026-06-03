import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_card_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/pitstop_logo.dart';
import '../widgets/primary_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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

  void _onSignUp() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: widget.email,
          password: values['password'] as String,
        );
  }

  String? _confirmPasswordValidator(String? value) {
    final password = _formKey.currentState?.fields['password']?.value as String?;
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
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
            AuthTextField(
              name: 'email',
              hintText: 'email@domain.com',
              keyboardType: TextInputType.emailAddress,
              initialValue: widget.email,
              enabled: false,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              name: 'password',
              hintText: 'Mật khẩu',
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Vui lòng nhập mật khẩu'),
                FormBuilderValidators.minLength(8, errorText: 'Mật khẩu tối thiểu 8 ký tự'),
              ]),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              name: 'confirmPassword',
              hintText: 'Xác nhận mật khẩu',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _confirmPasswordValidator,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Tạo tài khoản',
              isLoading: isLoading,
              onPressed: isLoading ? null : _onSignUp,
            ),
            const Spacer(),
            _LoginLink(),
          ],
        ),
      ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF888888)),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
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
