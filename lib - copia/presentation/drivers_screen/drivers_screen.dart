import 'dart:ui';

import 'package:flutter/material.dart';

import '../../widgets/empty_state_widget.dart';
import './widgets/driver_list_card_widget.dart';
import './widgets/grouped_section_header_widget.dart';

class DriverModel {
  final String id;
  final String fullName;
  final String initials;
  final Color avatarColor;
  final String assignedMoto;
  final double debtAmount;
  final String status;
  final int daysActive;
  final double docCompletionPercent;
  final bool hasIne;
  final bool hasAddressProof;
  final String platform;
  final int kmReading;

  const DriverModel({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.avatarColor,
    required this.assignedMoto,
    required this.debtAmount,
    required this.status,
    required this.daysActive,
    required this.docCompletionPercent,
    required this.hasIne,
    required this.hasAddressProof,
    required this.platform,
    required this.kmReading,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      initials: map['initials'] as String,
      avatarColor: Color(map['avatarColor'] as int),
      assignedMoto: map['assignedMoto'] as String,
      debtAmount: (map['debtAmount'] as num).toDouble(),
      status: map['status'] as String,
      daysActive: map['daysActive'] as int,
      docCompletionPercent: (map['docCompletionPercent'] as num).toDouble(),
      hasIne: map['hasIne'] as bool,
      hasAddressProof: map['hasAddressProof'] as bool,
      platform: map['platform'] as String,
      kmReading: map['kmReading'] as int,
    );
  }
}

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  late List<DriverModel> _drivers;
  late TextEditingController _searchController;

  final Set<String> _collapsedGroups = {};

  static final List<Map<String, dynamic>> _driverMaps = [
    {
      'id': 'D001',
      'fullName': 'Carlos Ramírez Vega',
      'initials': 'CR',
      'avatarColor': 0xFF7F1D1D,
      'assignedMoto': 'MF-07',
      'debtAmount': 2400.0,
      'status': 'indebted',
      'daysActive': 142,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'DiDi Food',
      'kmReading': 41350,
    },
    {
      'id': 'D002',
      'fullName': 'Luis Mendoza Ortiz',
      'initials': 'LM',
      'avatarColor': 0xFF7F1D1D,
      'assignedMoto': 'MF-03',
      'debtAmount': 1800.0,
      'status': 'indebted',
      'daysActive': 88,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'Rappi',
      'kmReading': 18450,
    },
    {
      'id': 'D003',
      'fullName': 'Miguel Gutiérrez Luna',
      'initials': 'MG',
      'avatarColor': 0xFF78350F,
      'assignedMoto': 'MF-05',
      'debtAmount': 950.0,
      'status': 'indebted',
      'daysActive': 204,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'Uber Eats',
      'kmReading': 29800,
    },
    {
      'id': 'D004',
      'fullName': 'Javier Torres Ruiz',
      'initials': 'JT',
      'avatarColor': 0xFF78350F,
      'assignedMoto': 'MF-11',
      'debtAmount': 1500.0,
      'status': 'indebted',
      'daysActive': 67,
      'docCompletionPercent': 50.0,
      'hasIne': true,
      'hasAddressProof': false,
      'platform': 'DiDi Food',
      'kmReading': 38900,
    },
    {
      'id': 'D005',
      'fullName': 'Sofía Herrera Paz',
      'initials': 'SH',
      'avatarColor': 0xFF064E3B,
      'assignedMoto': 'MF-01',
      'debtAmount': 0.0,
      'status': 'active',
      'daysActive': 312,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'Uber Eats',
      'kmReading': 22450,
    },
    {
      'id': 'D006',
      'fullName': 'Andrés Castillo Vega',
      'initials': 'AC',
      'avatarColor': 0xFF1E3A5F,
      'assignedMoto': 'MF-02',
      'debtAmount': 0.0,
      'status': 'active',
      'daysActive': 189,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'DiDi Food',
      'kmReading': 31200,
    },
    {
      'id': 'D007',
      'fullName': 'Patricia Flores Díaz',
      'initials': 'PF',
      'avatarColor': 0xFF1E3A5F,
      'assignedMoto': 'MF-14',
      'debtAmount': 0.0,
      'status': 'active',
      'daysActive': 45,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'Rappi',
      'kmReading': 11200,
    },
    {
      'id': 'D008',
      'fullName': 'Roberto Sánchez Mora',
      'initials': 'RS',
      'avatarColor': 0xFF4C1D95,
      'assignedMoto': 'MF-08',
      'debtAmount': 0.0,
      'status': 'active',
      'daysActive': 23,
      'docCompletionPercent': 100.0,
      'hasIne': true,
      'hasAddressProof': true,
      'platform': 'Uber Eats',
      'kmReading': 8750,
    },
    {
      'id': 'D009',
      'fullName': 'Gabriela Moreno Ríos',
      'initials': 'GM',
      'avatarColor': 0xFF78350F,
      'assignedMoto': '—',
      'debtAmount': 0.0,
      'status': 'pending',
      'daysActive': 0,
      'docCompletionPercent': 50.0,
      'hasIne': true,
      'hasAddressProof': false,
      'platform': '—',
      'kmReading': 0,
    },
    {
      'id': 'D010',
      'fullName': 'Eduardo PérezNava',
      'initials': 'EP',
      'avatarColor': 0xFF78350F,
      'assignedMoto': '—',
      'debtAmount': 0.0,
      'status': 'pending',
      'daysActive': 0,
      'docCompletionPercent': 0.0,
      'hasIne': false,
      'hasAddressProof': false,
      'platform': '—',
      'kmReading': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Replace with Riverpod/Bloc for production
    _drivers = _driverMaps.map(DriverModel.fromMap).toList();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DriverModel> get _filteredDrivers {
    return _drivers.where((d) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          d.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.assignedMoto.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'Todos' ||
          (_selectedFilter == 'Adeudo' && d.status == 'indebted') ||
          (_selectedFilter == 'Activos' && d.status == 'active') ||
          (_selectedFilter == 'Pendientes' && d.status == 'pending');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<DriverModel> _groupBy(String status) =>
      _filteredDrivers.where((d) => d.status == status).toList();

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  void _toggleGroup(String groupKey) {
    setState(() {
      if (_collapsedGroups.contains(groupKey)) {
        _collapsedGroups.remove(groupKey);
      } else {
        _collapsedGroups.add(groupKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final indebtedDrivers = _groupBy('indebted');
    final activeDrivers = _groupBy('active');
    final pendingDrivers = _groupBy('pending');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: const Text(
          'Agregar conductor',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
                          Text(
                            'Conductores',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFE8E8F0),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF7C3AED).withAlpha(102),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${_drivers.length} registrados',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFA78BFA),
                              ),
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

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF7C3AED),
              backgroundColor: const Color(0xFF1A1A2E),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),

                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _SearchBarWidget(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: _FilterChipsWidget(
                        selected: _selectedFilter,
                        onChanged: (v) => setState(() => _selectedFilter = v),
                        indebtedCount: _groupBy('indebted').length,
                        activeCount: _groupBy('active').length,
                        pendingCount: _groupBy('pending').length,
                      ),
                    ),
                  ),

                  // Indebted group
                  if (indebtedDrivers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: GroupedSectionHeaderWidget(
                          label: 'Con Adeudo',
                          count: indebtedDrivers.length,
                          isCollapsed: _collapsedGroups.contains('indebted'),
                          onToggle: () => _toggleGroup('indebted'),
                          accentColor: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    if (!_collapsedGroups.contains('indebted'))
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: DriverListCardWidget(
                              driver: indebtedDrivers[index],
                            ),
                          ),
                          childCount: indebtedDrivers.length,
                        ),
                      ),
                  ],

                  // Active group
                  if (activeDrivers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: GroupedSectionHeaderWidget(
                          label: 'Activos',
                          count: activeDrivers.length,
                          isCollapsed: _collapsedGroups.contains('active'),
                          onToggle: () => _toggleGroup('active'),
                          accentColor: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    if (!_collapsedGroups.contains('active'))
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: DriverListCardWidget(
                              driver: activeDrivers[index],
                            ),
                          ),
                          childCount: activeDrivers.length,
                        ),
                      ),
                  ],

                  // Pending group
                  if (pendingDrivers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: GroupedSectionHeaderWidget(
                          label: 'Pendientes de documentos',
                          count: pendingDrivers.length,
                          isCollapsed: _collapsedGroups.contains('pending'),
                          onToggle: () => _toggleGroup('pending'),
                          accentColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    if (!_collapsedGroups.contains('pending'))
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: DriverListCardWidget(
                              driver: pendingDrivers[index],
                            ),
                          ),
                          childCount: pendingDrivers.length,
                        ),
                      ),
                  ],

                  // Empty state
                  if (_filteredDrivers.isEmpty)
                    SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.people_outline_rounded,
                        title: 'Sin conductores',
                        subtitle:
                            'No hay conductores que coincidan con tu búsqueda. Agrega un nuevo conductor para comenzar.',
                        actionLabel: 'Agregar conductor',
                        onAction: () {},
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarWidget({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withAlpha(179),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFFE8E8F0), fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Buscar conductor o moto...',
              hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipsWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final int indebtedCount;
  final int activeCount;
  final int pendingCount;

  const _FilterChipsWidget({
    required this.selected,
    required this.onChanged,
    required this.indebtedCount,
    required this.activeCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {
        'label': 'Todos',
        'color': const Color(0xFF7C3AED),
        'count': indebtedCount + activeCount + pendingCount,
      },
      {
        'label': 'Adeudo',
        'color': const Color(0xFFEF4444),
        'count': indebtedCount,
      },
      {
        'label': 'Activos',
        'color': const Color(0xFF10B981),
        'count': activeCount,
      },
      {
        'label': 'Pendientes',
        'color': const Color(0xFFF59E0B),
        'count': pendingCount,
      },
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = selected == f['label'];
          final color = f['color'] as Color;
          final count = f['count'] as int;

          return GestureDetector(
            onTap: () => onChanged(f['label'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(51)
                    : const Color(0xFF1A1A2E).withAlpha(179),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? color.withAlpha(153)
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          ? color.withAlpha(64)
                          : const Color(0xFF2A2A45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
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
