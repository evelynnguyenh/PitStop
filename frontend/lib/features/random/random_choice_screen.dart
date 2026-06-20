import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/pitstop_logo.dart';
import 'random_screen.dart';

class RandomChoiceScreen extends StatelessWidget {
  const RandomChoiceScreen({super.key});

  void _openRandomScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RandomScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            const PitStopLogo(size: 60),

            const SizedBox(height: 12),

            const Text(
              'đang chọn điểm dừng tiếp theo...',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(34, 24, 34, 34),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      AppColors.background,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _ChoiceCard(
                        icon: Icons.person_outline,
                        title: 'Random cho mình',
                        subtitle: 'Dựa trên sở thích ăn uống của bạn',
                        onTap: () => _openRandomScreen(context),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Expanded(
                      child: _ChoiceCard(
                        icon: Icons.group_outlined,
                        title: 'Random theo nhóm',
                        subtitle: 'Cân bằng sở thích của cả nhóm',
                        onTap: () => _openRandomScreen(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(36),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFF4F4F4),
                child: Icon(
                  icon,
                  size: 42,
                  color: Color(0xFFFFB800),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF262626),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF5F5F5F),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}