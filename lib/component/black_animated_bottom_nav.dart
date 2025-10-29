import 'package:flutter/material.dart';

class BlackAnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BlackAnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.mic, label: "Record"),
      _NavItem(icon: Icons.history, label: "Journals"),
      _NavItem(icon: Icons.bar_chart, label: "Stats"),
    ];

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 78,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(26),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: currentIndex * itemWidth + 12,
                  top: 11,
                  width: itemWidth - 24,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (i) {
                    final selected = i == currentIndex;
                    final item = items[i];
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => onTap(i),
                        child: Center(
                          child: SizedBox(
                            height: 56,
                            width: itemWidth - 24,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.45),
                                  fontWeight: FontWeight.w700,
                                  fontSize: selected ? 15 : 14,
                                ),
                                child: Center(
                                  child: Icon(
                                    item.icon,
                                    size: 24,
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.55),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
