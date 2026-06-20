import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedDistance = 'Gần nhất';
  String selectedPrice = 'Bất kỳ';

  final List<String> cuisines = [
    'Phở',
    'Bún bò',
    'Cơm',
    'Đồ nướng',
    'Cafe',
    'Trà sữa',
  ];

  final Set<String> selectedCuisines = {};

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (selectedCuisines.contains(cuisine)) {
        selectedCuisines.remove(cuisine);
      } else {
        selectedCuisines.add(cuisine);
      }
    });
  }

  void _applyFilter() {
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      selectedDistance = 'Gần nhất';
      selectedPrice = 'Bất kỳ';
      selectedCuisines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const _SectionTitle(title: 'Khoảng cách'),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterChip(
                  label: 'Gần nhất',
                  selected: selectedDistance == 'Gần nhất',
                  onTap: () {
                    setState(() => selectedDistance = 'Gần nhất');
                  },
                ),
                _FilterChip(
                  label: '< 1 km',
                  selected: selectedDistance == '< 1 km',
                  onTap: () {
                    setState(() => selectedDistance = '< 1 km');
                  },
                ),
                _FilterChip(
                  label: '< 3 km',
                  selected: selectedDistance == '< 3 km',
                  onTap: () {
                    setState(() => selectedDistance = '< 3 km');
                  },
                ),
                _FilterChip(
                  label: '< 5 km',
                  selected: selectedDistance == '< 5 km',
                  onTap: () {
                    setState(() => selectedDistance = '< 5 km');
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            const _SectionTitle(title: 'Loại món'),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cuisines.map((cuisine) {
                return _FilterChip(
                  label: cuisine,
                  selected: selectedCuisines.contains(cuisine),
                  onTap: () => _toggleCuisine(cuisine),
                );
              }).toList(),
            ),

            const SizedBox(height: 26),

            const _SectionTitle(title: 'Mức giá'),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FilterChip(
                  label: 'Bất kỳ',
                  selected: selectedPrice == 'Bất kỳ',
                  onTap: () {
                    setState(() => selectedPrice = 'Bất kỳ');
                  },
                ),
                _FilterChip(
                  label: '\$',
                  selected: selectedPrice == '\$',
                  onTap: () {
                    setState(() => selectedPrice = '\$');
                  },
                ),
                _FilterChip(
                  label: '\$\$',
                  selected: selectedPrice == '\$\$',
                  onTap: () {
                    setState(() => selectedPrice = '\$\$');
                  },
                ),
                _FilterChip(
                  label: '\$\$\$',
                  selected: selectedPrice == '\$\$\$',
                  onTap: () {
                    setState(() => selectedPrice = '\$\$\$');
                  },
                ),
              ],
            ),

            const SizedBox(height: 34),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(
                        color: AppColors.green,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Áp dụng',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF222222),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.green,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.green : const Color(0xFFE0E0E0),
        width: 1.5,
      ),
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        color: selected ? Colors.white : const Color(0xFF333333),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}