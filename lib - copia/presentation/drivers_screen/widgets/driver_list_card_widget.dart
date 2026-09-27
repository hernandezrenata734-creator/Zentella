import 'dart:ui';
import 'package:flutter/material.dart';
import '../drivers_screen.dart';
import '../../../widgets/status_badge_widget.dart';

class DriverListCardWidget extends StatelessWidget {
  final DriverModel driver;

  const DriverListCardWidget({required this.driver, super.key});

  StatusType get _statusType {
    switch (driver.status) {
      case 'indebted':
        return StatusType.indebted;
      case 'active':
        return StatusType.active;
      case 'pending':
        return StatusType.pending;
      default:
        return StatusType.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDebt = driver.debtAmount > 0;
    final docIncomplete = driver.docCompletionPercent < 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withAlpha(191),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDebt
                  ? const Color(0xFFEF4444).withAlpha(89)
                  : docIncomplete
                  ? const Color(0xFFF59E0B).withAlpha(77)
                  : const Color(0x22FFFFFF),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + name + status badge + debt
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: driver.avatarColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        driver.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFFE8E8F0),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            StatusBadgeWidget(status: _statusType),
                            const SizedBox(width: 6),
                            Text(
                              driver.platform == '—'
                                  ? 'Sin plataforma'
                                  : driver.platform,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7280),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Debt amount
                  if (hasDebt)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${driver.debtAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFCA5A5),
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Text(
                          'adeudo',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 10),
              Container(height: 1, color: const Color(0xFF2A2A45)),
              const SizedBox(height: 10),

              // Metadata row
              Row(
                children: [
                  // Moto assigned
                  _MetaChip(
                    icon: Icons.two_wheeler_rounded,
                    label: driver.assignedMoto,
                    color: driver.assignedMoto == '—'
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFA78BFA),
                  ),
                  const SizedBox(width: 8),
                  // Days active
                  _MetaChip(
                    icon: Icons.calendar_today_rounded,
                    label: driver.daysActive == 0
                        ? 'Nuevo'
                        : '${driver.daysActive}d',
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  // Km
                  if (driver.kmReading > 0)
                    _MetaChip(
                      icon: Icons.speed_rounded,
                      label:
                          '${(driver.kmReading / 1000).toStringAsFixed(1)}k km',
                      color: const Color(0xFF6B7280),
                    ),
                  const Spacer(),
                  // Chevron
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF3A3A5C),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Document completion bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _DocBadge(label: 'INE', isComplete: driver.hasIne),
                          const SizedBox(width: 6),
                          _DocBadge(
                            label: 'Domicilio',
                            isComplete: driver.hasAddressProof,
                          ),
                        ],
                      ),
                      Text(
                        '${driver.docCompletionPercent.toInt()}% docs',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: driver.docCompletionPercent == 100
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFFFCD34D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: driver.docCompletionPercent / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF2A2A45),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        driver.docCompletionPercent == 100
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocBadge extends StatelessWidget {
  final String label;
  final bool isComplete;

  const _DocBadge({required this.label, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isComplete
            ? const Color(0xFF064E3B).withAlpha(153)
            : const Color(0xFF7F1D1D).withAlpha(128),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isComplete
              ? const Color(0xFF10B981).withAlpha(102)
              : const Color(0xFFEF4444).withAlpha(102),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 10,
            color: isComplete
                ? const Color(0xFF6EE7B7)
                : const Color(0xFFFCA5A5),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isComplete
                  ? const Color(0xFF6EE7B7)
                  : const Color(0xFFFCA5A5),
            ),
          ),
        ],
      ),
    );
  }
}
