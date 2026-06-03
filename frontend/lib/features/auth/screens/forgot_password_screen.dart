import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/auth_card_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/pitstop_logo.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _submitted = false;

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    setState(() => _isLoading = true);

    // TODO(backend): call POST /auth/forgot-password when backend is live
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthCardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: PitStopLogo()),
          const SizedBox(height: 20),
          const Text(
            'Quên mật khẩu?',
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
            'Nhập email để nhận hướng dẫn đặt lại mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (_submitted) ...[
            _SuccessMessage(),
          ] else ...[
            FormBuilder(
              key: _formKey,
              child: AuthTextField(
                name: 'email',
                hintText: 'email@domain.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Vui lòng nhập email'),
                  FormBuilderValidators.email(errorText: 'Email không hợp lệ'),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Gửi email',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _onSubmit,
            ),
          ],
          const Spacer(),
          _BackToLoginLink(),
        ],
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle_outline, color: AppColors.green, size: 48),
        SizedBox(height: 16),
        Text(
          'Chúng tôi đã gửi email hướng dẫn. Kiểm tra hộp thư của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: Color(0xFF1A1A1A),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BackToLoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Quay lại ',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF888888)),
        ),
        GestureDetector(
          onTap: () => context.pop(),
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
