import 'dart:ui';
import 'package:flutter/material.dart';

class _KpiData {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final String trend;
  final bool trendPositive;

  const _KpiData({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.trend,
    required this.trendPositive,
  });
}

class KpiMetricsGridWidget extends StatelessWidget {
  const KpiMetricsGridWidget({super.key});

  static const List<_KpiData> _metrics = [
    _KpiData(
      label: 'Ingresos del mes',
      value: '\$47,200',
      unit: 'MXN',
      icon: Icons.attach_money_rounded,
      accentColor: Color(0xFF10B981),
      trend: '+12%',
      trendPositive: true,
    ),
    _KpiData(
      label: 'Adeudo total',
      value: '\$8,650',
      unit: 'MXN',
      icon: Icons.warning_amber_rounded,
      accentColor: Color(0xFFEF4444),
      trend: '+3 conductores',
      trendPositive: false,
    ),
    _KpiData(
      label: 'Motos activas',
      value: '14',
      unit: 'de 18',
      icon: Icons.two_wheeler_rounded,
      accentColor: Color(0xFF3B82F6),
      trend: '77.8%',
      trendPositive: true,
    ),
    _KpiData(
      label: 'Requieren servicio',
      value: '3',
      unit: 'motos',
      icon: Icons.build_circle_outlined,
      accentColor: Color(0xFFF59E0B),
      trend: '!Urgente',
      trendPositive: false,
    ),
    _KpiData(
      label: 'Utilización',
      value: '77.8',
      unit: '%',
      icon: Icons.donut_large_rounded,
      accentColor: Color(0xFF7C3AED),
      trend: '+5.2%',
      trendPositive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Métricas clave',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFE8E8F0),
              ),
            ),
            Text(
              'Sep 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
          ),
          itemCount: _metrics.length,
          itemBuilder: (context, index) {
            final m = _metrics[index];
            // Last item spans full width — handled via Stack trick
            return _KpiCard(data: m);
          },
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withAlpha(179),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: data.accentColor.withAlpha(77), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: data.accentColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(data.icon, size: 16, color: data.accentColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: data.trendPositive
                          ? const Color(0xFF064E3B)
                          : const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.trendPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 9,
                          color: data.trendPositive
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFFFCA5A5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data.trend,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: data.trendPositive
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFFFCA5A5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: data.accentColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          data.unit,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: data.accentColor.withAlpha(179),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
