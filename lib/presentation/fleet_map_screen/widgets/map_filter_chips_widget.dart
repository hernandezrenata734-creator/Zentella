import 'package:flutter/material.dart';

class MapFilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ScrollController? scrollController;

  const MapFilterChipsWidget({
    required this.selectedFilter,
    required this.onFilterChanged,
    this.scrollController,
    super.key,
  });

  static const List<Map<String, dynamic>> _filters = [
    {'label': 'Todos', 'count': 18, 'color': Color(0xFF7C3AED)},
    {'label': 'Activas', 'count': 14, 'color': Color(0xFF10B981)},
    {'label': 'En reposo', 'count': 2, 'color': Color(0xFFF59E0B)},
    {'label': 'Servicio', 'count': 1, 'color': Color(0xFF3B82F6)},
    {'label': 'Offline', 'count': 1, 'color': Color(0xFF6B7280)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final isSelected = selectedFilter == f['label'];
          final color = f['color'] as Color;

          return GestureDetector(
            onTap: () => onFilterChanged(f['label'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(64)
                    : const Color(0xFF1A1A2E).withAlpha(204),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? color.withAlpha(179)
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? color : const Color(0xFFAAABBD),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(77)
                          : const Color(0xFF2A2A45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${f['count']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
