import 'dart:ui';

import 'package:flutter/material.dart';

import './widgets/debt_alert_list_widget.dart';
import './widgets/fleet_status_cards_widget.dart';
import './widgets/fleet_summary_card_widget.dart';
import './widgets/kpi_metrics_grid_widget.dart';
import './widgets/recent_activity_section_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  bool _isLoading = false;

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // Glassmorphism AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: const Color(0xFF0F0F1A).withAlpha(179),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Avatar + greeting
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'ML',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buenos días',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  'María López',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE8E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification bell
                          Stack(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A2E).withAlpha(204),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0x33FFFFFF),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFFE8E8F0),
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Stats icon
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF7C3AED).withAlpha(128),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.bar_chart_rounded,
                              color: Color(0xFFA78BFA),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF7C3AED),
              backgroundColor: const Color(0xFF1A1A2E),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Spacer for AppBar height
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),

                  // Fleet Summary Card (AI-style hero card)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const FleetSummaryCardWidget(),
                    ),
                  ),

                  // KPI Metrics Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const KpiMetricsGridWidget(),
                    ),
                  ),

                  // Two-column middle section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: isTablet
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Expanded(
                                  flex: 55,
                                  child: DebtAlertListWidget(),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 45,
                                  child: FleetStatusCardsWidget(),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Expanded(
                                  flex: 55,
                                  child: DebtAlertListWidget(),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 45,
                                  child: FleetStatusCardsWidget(),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Recent Activity Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const RecentActivitySectionWidget(),
                    ),
                  ),

                  // Bottom padding for nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
