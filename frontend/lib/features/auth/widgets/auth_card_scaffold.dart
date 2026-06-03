import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthCardScaffold extends StatelessWidget {
  const AuthCardScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              width: double.infinity,
              height: constraints.maxHeight,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, innerConstraints) => SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: innerConstraints.maxHeight,
                    ),
                    child: IntrinsicHeight(child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
