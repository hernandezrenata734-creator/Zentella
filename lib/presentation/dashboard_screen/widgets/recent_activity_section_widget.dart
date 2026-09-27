import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/status_badge_widget.dart';

class _ActivityItem {
  final String driverName;
  final String motoId;
  final String action;
  final String amount;
  final String time;
  final String platform;
  final StatusType status;
  final String avatarInitials;
  final Color avatarColor;

  const _ActivityItem({
    required this.driverName,
    required this.motoId,
    required this.action,
    required this.amount,
    required this.time,
    required this.platform,
    required this.status,
    required this.avatarInitials,
    required this.avatarColor,
  });
}

class RecentActivitySectionWidget extends StatelessWidget {
  const RecentActivitySectionWidget({super.key});

  static const List<_ActivityItem> _activities = [
    _ActivityItem(
      driverName: 'Carlos Ramírez Vega',
      motoId: 'MF-07',
      action: 'Pago semanal',
      amount: '\$1,200',
      time: '09:30 - 10:00',
      platform: 'Uber Eats',
      status: StatusType.indebted,
      avatarInitials: 'CR',
      avatarColor: Color(0xFF7F1D1D),
    ),
    _ActivityItem(
      driverName: 'Luis Mendoza Ortiz',
      motoId: 'MF-03',
      action: 'Renta activa',
      amount: '\$800',
      time: '08:00 - 08:15',
      platform: 'DiDi Food',
      status: StatusType.active,
      avatarInitials: 'LM',
      avatarColor: Color(0xFF064E3B),
    ),
    _ActivityItem(
      driverName: 'Javier Torres Ruiz',
      motoId: 'MF-11',
      action: 'Servicio programado',
      amount: '—',
      time: '07:45',
      platform: 'Rappi',
      status: StatusType.inService,
      avatarInitials: 'JT',
      avatarColor: Color(0xFF1E3A5F),
    ),
    _ActivityItem(
      driverName: 'Miguel Gutiérrez Luna',
      motoId: 'MF-05',
      action: 'Adeudo pendiente',
      amount: '\$950',
      time: 'Ayer 18:30',
      platform: 'Uber Eats',
      status: StatusType.indebted,
      avatarInitials: 'MG',
      avatarColor: Color(0xFF7F1D1D),
    ),
    _ActivityItem(
      driverName: 'Sofía Herrera Paz',
      motoId: 'MF-02',
      action: 'Pago completado',
      amount: '\$1,200',
      time: 'Ayer 15:00',
      platform: 'DiDi Food',
      status: StatusType.completed,
      avatarInitials: 'SH',
      avatarColor: Color(0xFF064E3B),
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
              'Actividad reciente',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFE8E8F0),
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.driversScreen),
              child: Row(
                children: [
                  Text(
                    'Ver todos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFA78BFA),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFFA78BFA),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._activities.map((a) => _ActivityCard(item: a)),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withAlpha(179),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x22FFFFFF), width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.avatarColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.avatarInitials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadgeWidget(status: item.status),
                          const SizedBox(width: 6),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFA78BFA),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.platform,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFA78BFA),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.driverName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFE8E8F0),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.motoId} · ${item.action}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.amount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: item.amount == '—'
                            ? const Color(0xFF6B7280)
                            : (item.status == StatusType.indebted
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF6EE7B7)),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
