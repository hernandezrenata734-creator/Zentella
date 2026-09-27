import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './widgets/map_bottom_sheet_widget.dart';

class FleetMapScreen extends StatefulWidget {
  const FleetMapScreen({super.key});

  @override
  State<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends State<FleetMapScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  String _selectedFilter = 'Todos';
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map area
          if (isTablet)
            Row(
              children: [
                Expanded(flex: 65, child: _MapArea()),
                Container(width: 1, color: const Color(0xFF2A2A45)),
                Expanded(
                  flex: 35,
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 72),
                        Expanded(
                          child: MapBottomSheetWidget(
                            selectedFilter: _selectedFilter,
                            onFilterChanged: (f) =>
                                setState(() => _selectedFilter = f),
                            isTablet: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            _MapArea(),

          // Glassmorphism AppBar overlay
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
                            'Flota en tiempo real',
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
                              color: const Color(0xFF10B981).withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF10B981).withAlpha(102),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  '14 activas',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                ),
                              ],
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

          // Draggable bottom sheet (phone only)
          if (!isTablet)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.35,
              minChildSize: 0.15,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xCC1A1A2E),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0x33FFFFFF), width: 1),
                        ),
                      ),
                      child: MapBottomSheetWidget(
                        scrollController: scrollController,
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (f) =>
                            setState(() => _selectedFilter = f),
                        isTablet: false,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        color: const Color(0xFF0D1117),
        child: Stack(
          children: [
            // Simulated map grid
            CustomPaint(painter: _MapGridPainter(), child: Container()),
            // Moto pins
            ..._mockPins.map(
              (pin) => Positioned(
                left: pin.x,
                top: pin.y,
                child: _MotoPin(motoId: pin.motoId, status: pin.status),
              ),
            ),
            // Web notice
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Mapa GPS disponible en dispositivo con API Key',
                    style: TextStyle(fontSize: 12, color: Color(0xFFAAABBD)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: Google Maps
    return Container(
      color: const Color(0xFF0D1117),
      child: Stack(
        children: [
          CustomPaint(painter: _MapGridPainter(), child: Container()),
          ..._mockPins.map(
            (pin) => Positioned(
              left: pin.x,
              top: pin.y,
              child: _MotoPin(motoId: pin.motoId, status: pin.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinData {
  final double x;
  final double y;
  final String motoId;
  final String status;

  const _PinData({
    required this.x,
    required this.y,
    required this.motoId,
    required this.status,
  });
}

const List<_PinData> _mockPins = [
  _PinData(x: 80, y: 180, motoId: 'MF-01', status: 'active'),
  _PinData(x: 160, y: 250, motoId: 'MF-03', status: 'active'),
  _PinData(x: 240, y: 160, motoId: 'MF-07', status: 'idle'),
  _PinData(x: 120, y: 340, motoId: 'MF-11', status: 'service'),
  _PinData(x: 280, y: 280, motoId: 'MF-14', status: 'active'),
  _PinData(x: 60, y: 420, motoId: 'MF-02', status: 'active'),
  _PinData(x: 200, y: 400, motoId: 'MF-09', status: 'offline'),
  _PinData(x: 320, y: 200, motoId: 'MF-05', status: 'idle'),
];

class _MotoPin extends StatefulWidget {
  final String motoId;
  final String status;

  const _MotoPin({required this.motoId, required this.status});

  @override
  State<_MotoPin> createState() => _MotoPinState();
}

class _MotoPinState extends State<_MotoPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    if (widget.status == 'active') {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat(reverse: true);
      _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
    } else {
      _pulseController = AnimationController(vsync: this);
      _pulseAnim = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _pinColor {
    switch (widget.status) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: GestureDetector(
            onTap: () => _showPinDetail(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _pinColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _pinColor.withAlpha(102),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.two_wheeler_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.motoId,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(8, 6),
                  painter: _TrianglePainter(color: _pinColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPinDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(102), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _pinColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.motoId,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _pinColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _detailRow(
                Icons.person_outline_rounded,
                'Conductor',
                'Luis Mendoza Ortiz',
              ),
              const SizedBox(height: 6),
              _detailRow(Icons.speed_rounded, 'Kilometraje', '18,450 km'),
              const SizedBox(height: 6),
              _detailRow(
                Icons.location_on_outlined,
                'Colonia',
                'Roma Norte, CDMX',
              ),
              const SizedBox(height: 6),
              _detailRow(
                Icons.access_time_rounded,
                'Últ. actualización',
                'Hace 2 min',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE8E8F0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
