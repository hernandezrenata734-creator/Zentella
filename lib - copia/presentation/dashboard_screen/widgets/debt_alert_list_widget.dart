import 'dart:ui';
import 'package:flutter/material.dart';

class _DebtAlert {
  final String driverName;
  final String amount;
  final int daysPending;
  final bool isCritical;

  const _DebtAlert({
    required this.driverName,
    required this.amount,
    required this.daysPending,
    required this.isCritical,
  });
}

class DebtAlertListWidget extends StatelessWidget {
  const DebtAlertListWidget({super.key});

  static const List<_DebtAlert> _alerts = [
    _DebtAlert(
      driverName: 'Ramírez',
      amount: '\$2,400',
      daysPending: 12,
      isCritical: true,
    ),
    _DebtAlert(
      driverName: 'Mendoza',
      amount: '\$1,800',
      daysPending: 7,
      isCritical: true,
    ),
    _DebtAlert(
      driverName: 'Gutiérrez',
      amount: '\$950',
      daysPending: 3,
      isCritical: false,
    ),
    _DebtAlert(
      driverName: 'Torres',
      amount: '\$1,500',
      daysPending: 9,
      isCritical: false,
    ),
  ];

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
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adeudos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFFE8E8F0),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_alerts.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFCA5A5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._alerts.map((a) => _DebtRow(alert: a)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  final _DebtAlert alert;

  const _DebtRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alert.isCritical
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              alert.driverName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8E8F0),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alert.amount,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFCA5A5),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${alert.daysPending}d',
                style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
