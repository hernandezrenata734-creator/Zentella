import 'package:flutter/material.dart';

class GroupedSectionHeaderWidget extends StatelessWidget {
  final String label;
  final int count;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final Color accentColor;

  const GroupedSectionHeaderWidget({
    required this.label,
    required this.count,
    required this.isCollapsed,
    required this.onToggle,
    required this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // Colored accent bar
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFE8E8F0),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            // Count chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(51),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accentColor.withAlpha(102), width: 1),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const Spacer(),
            // Collapse toggle
            AnimatedRotation(
              turns: isCollapsed ? -0.25 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
