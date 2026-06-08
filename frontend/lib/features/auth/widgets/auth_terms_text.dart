import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthTermsText extends StatefulWidget {
  const AuthTermsText({super.key});

  @override
  State<AuthTermsText> createState() => _AuthTermsTextState();
}

class _AuthTermsTextState extends State<AuthTermsText> {
  late final TapGestureRecognizer _legalRecognizer;

  @override
  void initState() {
    super.initState();
    _legalRecognizer = TapGestureRecognizer()
      ..onTap = () => _show('Điều khoản dịch vụ và Chính sách bảo mật');
  }

  @override
  void dispose() {
    _legalRecognizer.dispose();
    super.dispose();
  }

  void _show(String title) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LegalSheet(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: Color(0xFFAAAAAA),
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'Bằng việc tiếp tục, bạn đồng ý với '),
          TextSpan(
            text: 'Điều khoản dịch vụ và Chính sách bảo mật',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
            recognizer: _legalRecognizer,
          ),
        ],
      ),
    );
  }
}

class _LegalSheet extends StatelessWidget {
  const _LegalSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: const Text(
                  'Nội dung đang được cập nhật. Vui lòng quay lại sau.\n\n'
                  'PitStop cam kết bảo vệ thông tin cá nhân của bạn và cung cấp '
                  'trải nghiệm tốt nhất. Các điều khoản chi tiết sẽ được công bố '
                  'trước khi ứng dụng ra mắt chính thức.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
