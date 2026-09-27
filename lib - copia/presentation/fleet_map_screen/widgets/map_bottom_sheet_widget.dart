import 'package:flutter/material.dart';

import './map_filter_chips_widget.dart';
import './moto_list_item_widget.dart';

class _MotoItem {
  final String motoId;
  final String driverName;
  final int kmReading;
  final String status;
  final String location;
  final String platform;
  final int serviceKmRemaining;

  const _MotoItem({
    required this.motoId,
    required this.driverName,
    required this.kmReading,
    required this.status,
    required this.location,
    required this.platform,
    required this.serviceKmRemaining,
  });
}

class MapBottomSheetWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final bool isTablet;

  const MapBottomSheetWidget({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isTablet,
    this.scrollController,
    super.key,
  });

  static const List<Map<String, dynamic>> _motoMaps = [
    {
      'motoId': 'MF-01',
      'driverName': 'Sofía Herrera Paz',
      'kmReading': 22450,
      'status': 'active',
      'location': 'Condesa, CDMX',
      'platform': 'Uber Eats',
      'serviceKmRemaining': 1550,
    },
    {
      'motoId': 'MF-02',
      'driverName': 'Andrés Castillo Vega',
      'kmReading': 31200,
      'status': 'active',
      'location': 'Polanco, CDMX',
      'platform': 'DiDi Food',
      'serviceKmRemaining': 800,
    },
    {
      'motoId': 'MF-03',
      'driverName': 'Luis Mendoza Ortiz',
      'kmReading': 18450,
      'status': 'active',
      'location': 'Roma Norte, CDMX',
      'platform': 'Rappi',
      'serviceKmRemaining': 3550,
    },
    {
      'motoId': 'MF-05',
      'driverName': 'Miguel Gutiérrez Luna',
      'kmReading': 29800,
      'status': 'idle',
      'location': 'Narvarte, CDMX',
      'platform': 'Uber Eats',
      'serviceKmRemaining': 200,
    },
    {
      'motoId': 'MF-07',
      'driverName': 'Carlos Ramírez Vega',
      'kmReading': 41350,
      'status': 'idle',
      'location': 'Doctores, CDMX',
      'platform': 'DiDi Food',
      'serviceKmRemaining': -200,
    },
    {
      'motoId': 'MF-09',
      'driverName': 'Sin asignar',
      'kmReading': 15600,
      'status': 'offline',
      'location': 'Desconocida',
      'platform': '—',
      'serviceKmRemaining': 4400,
    },
    {
      'motoId': 'MF-11',
      'driverName': 'Javier Torres Ruiz',
      'kmReading': 38900,
      'status': 'service',
      'location': 'Taller Sur, CDMX',
      'platform': '—',
      'serviceKmRemaining': -900,
    },
    {
      'motoId': 'MF-14',
      'driverName': 'Patricia Flores Díaz',
      'kmReading': 11200,
      'status': 'active',
      'location': 'Coyoacán, CDMX',
      'platform': 'Rappi',
      'serviceKmRemaining': 8800,
    },
  ];

  List<_MotoItem> get _motos => _motoMaps
      .map(
        (m) => _MotoItem(
          motoId: m['motoId'] as String,
          driverName: m['driverName'] as String,
          kmReading: m['kmReading'] as int,
          status: m['status'] as String,
          location: m['location'] as String,
          platform: m['platform'] as String,
          serviceKmRemaining: m['serviceKmRemaining'] as int,
        ),
      )
      .where((m) {
        if (selectedFilter == 'Todos') return true;
        if (selectedFilter == 'Activas') return m.status == 'active';
        if (selectedFilter == 'En reposo') return m.status == 'idle';
        if (selectedFilter == 'Servicio') return m.status == 'service';
        if (selectedFilter == 'Offline') return m.status == 'offline';
        return true;
      })
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motos = _motos;

    return Column(
      children: [
        if (!isTablet) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A5C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 16),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Todas las motos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              Text(
                '${motos.length} unidades',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter chips
        MapFilterChipsWidget(
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 12),

        // Moto list
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: motos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return MotoListItemWidget(moto: motos[index]);
            },
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
