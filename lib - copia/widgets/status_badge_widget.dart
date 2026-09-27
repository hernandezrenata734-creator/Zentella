import 'package:flutter/material.dart';

enum StatusType {
  active,
  idle,
  offline,
  alert,
  indebted,
  pending,
  inService,
  completed,
  high,
  low,
  medium,
}

class StatusBadgeWidget extends StatelessWidget {
  final StatusType status;
  final String? customLabel;
  final double fontSize;
  final EdgeInsets? padding;

  const StatusBadgeWidget({
    required this.status,
    this.customLabel,
    this.fontSize = 11,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Text(
        customLabel ?? config.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: config.textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _BadgeConfig _getConfig(StatusType s) {
    switch (s) {
      case StatusType.active:
        return _BadgeConfig(
          label: 'Activo',
          bgColor: const Color(0xFF064E3B),
          borderColor: const Color(0xFF10B981),
          textColor: const Color(0xFF6EE7B7),
        );
      case StatusType.idle:
        return _BadgeConfig(
          label: 'En reposo',
          bgColor: const Color(0xFF78350F),
          borderColor: const Color(0xFFF59E0B),
          textColor: const Color(0xFFFCD34D),
        );
      case StatusType.offline:
        return _BadgeConfig(
          label: 'Offline',
          bgColor: const Color(0xFF374151),
          borderColor: const Color(0xFF6B7280),
          textColor: const Color(0xFFD1D5DB),
        );
      case StatusType.alert:
        return _BadgeConfig(
          label: 'Alerta',
          bgColor: const Color(0xFF7F1D1D),
          borderColor: const Color(0xFFEF4444),
          textColor: const Color(0xFFFCA5A5),
        );
      case StatusType.indebted:
        return _BadgeConfig(
          label: 'Adeudo',
          bgColor: const Color(0xFF7F1D1D),
          borderColor: const Color(0xFFEF4444),
          textColor: const Color(0xFFFCA5A5),
        );
      case StatusType.pending:
        return _BadgeConfig(
          label: 'Pendiente',
          bgColor: const Color(0xFF78350F),
          borderColor: const Color(0xFFF59E0B),
          textColor: const Color(0xFFFCD34D),
        );
      case StatusType.inService:
        return _BadgeConfig(
          label: 'En servicio',
          bgColor: const Color(0xFF1E3A5F),
          borderColor: const Color(0xFF3B82F6),
          textColor: const Color(0xFF93C5FD),
        );
      case StatusType.completed:
        return _BadgeConfig(
          label: 'Completado',
          bgColor: const Color(0xFF064E3B),
          borderColor: const Color(0xFF10B981),
          textColor: const Color(0xFF6EE7B7),
        );
      case StatusType.high:
        return _BadgeConfig(
          label: 'Alta',
          bgColor: const Color(0xFF7F1D1D),
          borderColor: const Color(0xFFEF4444),
          textColor: const Color(0xFFFCA5A5),
        );
      case StatusType.medium:
        return _BadgeConfig(
          label: 'Media',
          bgColor: const Color(0xFF78350F),
          borderColor: const Color(0xFFF59E0B),
          textColor: const Color(0xFFFCD34D),
        );
      case StatusType.low:
        return _BadgeConfig(
          label: 'Baja',
          bgColor: const Color(0xFF064E3B),
          borderColor: const Color(0xFF10B981),
          textColor: const Color(0xFF6EE7B7),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _BadgeConfig({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
