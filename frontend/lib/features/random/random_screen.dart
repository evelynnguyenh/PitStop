import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../data/models/restaurant.dart';
import '../../widgets/pitstop_logo.dart';
import '../../widgets/restaurant_card.dart';
import 'filter_screen.dart';

class RandomScreen extends StatefulWidget {
  const RandomScreen({super.key});

  @override
  State<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen> {
  Restaurant current = mockRestaurants.first;

  void _randomize() {
    final random = Random();

    setState(() {
      current = mockRestaurants[random.nextInt(mockRestaurants.length)];
    });
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterScreen(),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _openFilter,
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            const PitStopLogo(size: 42),

            const SizedBox(height: 6),

            const Text(
              'đang chọn điểm dừng tiếp theo...',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 52),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24),
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
                    Transform.rotate(
                      angle: -0.08,
                      child: RestaurantCard(
                        restaurant: current,
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        34,
                        0,
                        34,
                        40,
                      ),
                      child: SizedBox(
                        height: 62,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _randomize,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Quay random',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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