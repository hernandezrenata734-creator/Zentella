import 'dart:ui';
import 'package:flutter/material.dart';

class MotoListItemWidget extends StatelessWidget {
  final dynamic moto;

  const MotoListItemWidget({required this.moto, super.key});

  Color get _statusColor {
    switch (moto.status as String) {
      case 'active':
        return const Color(0xFF10B981);
      case 'idle':
        return const Color(0xFFF59E0B);
      case 'service':
        return const Color(0xFF3B82F6);
      case 'offline':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF10B981);
    }
  }

  String get _statusLabel {
    switch (moto.status as String) {
      case 'active':
        return 'Activa';
      case 'idle':
        return 'En reposo';
      case 'service':
        return 'Servicio';
      case 'offline':
        return 'Offline';
      default:
        return 'Activa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kmRemaining = moto.serviceKmRemaining as int;
    final isServiceDue = kmRemaining <= 0;
    final isServiceSoon = kmRemaining > 0 && kmRemaining <= 500;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withAlpha(179),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isServiceDue
                  ? const Color(0xFFEF4444).withAlpha(128)
                  : isServiceSoon
                  ? const Color(0xFFF59E0B).withAlpha(102)
                  : const Color(0x22FFFFFF),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Moto ID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _statusColor.withAlpha(102),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.two_wheeler_rounded,
                      size: 16,
                      color: _statusColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      moto.motoId as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            moto.driverName as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              color: const Color(0xFFE8E8F0),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            moto.location as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 10,
                          color: Color(0xFFAAABBD),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${(moto.kmReading as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAAABBD),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Service indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isServiceDue
                                ? const Color(0xFF7F1D1D)
                                : isServiceSoon
                                ? const Color(0xFF78350F)
                                : const Color(0xFF064E3B).withAlpha(128),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isServiceDue
                                ? '¡Servicio ya!'
                                : isServiceSoon
                                ? 'Servicio: ${kmRemaining}km'
                                : 'OK ${kmRemaining}km',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isServiceDue
                                  ? const Color(0xFFFCA5A5)
                                  : isServiceSoon
                                  ? const Color(0xFFFCD34D)
                                  : const Color(0xFF6EE7B7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
