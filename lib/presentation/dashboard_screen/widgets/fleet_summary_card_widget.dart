import 'dart:ui';
import 'package:flutter/material.dart';

class FleetSummaryCardWidget extends StatelessWidget {
  const FleetSummaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4C1D95).withAlpha(153),
                const Color(0xFF1A1A2E).withAlpha(204),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF7C3AED).withAlpha(102),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge + label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E).withAlpha(153),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '26 Sep',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFAAABBD),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withAlpha(77),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Resumen IA',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFA78BFA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Análisis de hoy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFAAABBD),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8E8F0),
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Tienes '),
                          TextSpan(
                            text: '3 motos',
                            style: TextStyle(color: Color(0xFFFCA5A5)),
                          ),
                          TextSpan(text: ' con servicio\npendiente.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Illustration area
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withAlpha(102),
                      const Color(0xFF4C1D95).withAlpha(26),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withAlpha(128),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: Color(0xFFA78BFA),
                  size: 34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
