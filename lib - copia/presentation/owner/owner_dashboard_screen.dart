import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _motos = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _pagos = [];
  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final client = SupabaseService.instance.client;
      final userId = AuthService.currentUserId;
      if (userId == null) return;

      final profileRes = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final motosRes = await client
          .from('motos')
          .select()
          .eq('owner_id', userId)
          .order('created_at');

      final driversRes = await client
          .from('driver_profiles')
          .select('*, user_profiles(*), motos(*)')
          .order('created_at');

      final pagosRes = await client
          .from('pagos')
          .select('*, driver_profiles(user_profiles(full_name))')
          .order('fecha_pago', ascending: false)
          .limit(20);

      final notifRes = await client
          .from('notificaciones')
          .select()
          .eq('user_id', userId)
          .eq('leida', false)
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _profile = profileRes;
          _motos = List<Map<String, dynamic>>.from(motosRes);
          _drivers = List<Map<String, dynamic>>.from(driversRes);
          _pagos = List<Map<String, dynamic>>.from(pagosRes);
          _notificaciones = List<Map<String, dynamic>>.from(notifRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _totalGanancias {
    return _pagos
        .where((p) => p['status'] == 'pagado')
        .fold(0.0, (sum, p) => sum + ((p['monto'] as num?)?.toDouble() ?? 0));
  }

  double get _totalDeuda {
    return _pagos
        .where((p) => p['status'] == 'pendiente' || p['status'] == 'vencido')
        .fold(0.0, (sum, p) => sum + ((p['monto'] as num?)?.toDouble() ?? 0));
  }

  int get _motosActivas => _motos.where((m) => m['status'] == 'activa').length;

  int get _conductoresActivos =>
      _drivers.where((d) => d['status'] == 'activo').length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final name = _profile?['full_name'] as String? ?? 'Propietaria';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
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
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
                                const Text(
                                  'Panel de control',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFFE8E8F0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              if (_notificaciones.isNotEmpty)
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
                          GestureDetector(
                            onTap: () async {
                              await AuthService.signOut();
                              if (mounted) context.go('/login');
                            },
                            child: Container(
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
                                Icons.logout_rounded,
                                color: Color(0xFF6B7280),
                                size: 18,
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
              onRefresh: _loadData,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surfaceDark,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 72)),
                  // KPI Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _KpiCard(
                                  label: 'Ganancias',
                                  value:
                                      '\$${_totalGanancias.toStringAsFixed(0)}',
                                  subtitle: 'MXN cobrado',
                                  icon: Icons.trending_up_rounded,
                                  color: AppTheme.success,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _KpiCard(
                                  label: 'Adeudos',
                                  value: '\$${_totalDeuda.toStringAsFixed(0)}',
                                  subtitle: 'MXN pendiente',
                                  icon: Icons.warning_amber_rounded,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiCard(
                                  label: 'Motos activas',
                                  value: '$_motosActivas / ${_motos.length}',
                                  subtitle: 'en servicio',
                                  icon: Icons.two_wheeler_rounded,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _KpiCard(
                                  label: 'Conductores',
                                  value:
                                      '$_conductoresActivos / ${_drivers.length}',
                                  subtitle: 'activos hoy',
                                  icon: Icons.people_rounded,
                                  color: AppTheme.info,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Alerts
                  if (_notificaciones.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alertas',
                              style: TextStyle(
                                color: Color(0xFFE8E8F0),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._notificaciones.take(3).map((n) {
                              final tipo = n['tipo'] as String? ?? 'info';
                              Color alertColor;
                              IconData alertIcon;
                              switch (tipo) {
                                case 'deuda':
                                  alertColor = AppTheme.error;
                                  alertIcon = Icons.warning_amber_rounded;
                                  break;
                                case 'mantenimiento':
                                  alertColor = AppTheme.warning;
                                  alertIcon = Icons.build_outlined;
                                  break;
                                case 'alerta':
                                  alertColor = AppTheme.warning;
                                  alertIcon =
                                      Icons.notifications_active_outlined;
                                  break;
                                default:
                                  alertColor = AppTheme.info;
                                  alertIcon = Icons.info_outline;
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: alertColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: alertColor.withAlpha(60),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      alertIcon,
                                      color: alertColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n['titulo'] as String? ?? '',
                                            style: TextStyle(
                                              color: alertColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            n['mensaje'] as String? ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  // Debt list
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Conductores con adeudo',
                            style: TextStyle(
                              color: Color(0xFFE8E8F0),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._pagos
                              .where(
                                (p) =>
                                    p['status'] == 'pendiente' ||
                                    p['status'] == 'vencido',
                              )
                              .take(5)
                              .map((p) {
                                final driverName =
                                    (p['driver_profiles']
                                            as Map<
                                              String,
                                              dynamic
                                            >?)?['user_profiles']?['full_name']
                                        as String? ??
                                    'Conductor';
                                final monto =
                                    (p['monto'] as num?)?.toDouble() ?? 0;
                                final status = p['status'] as String? ?? '';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceDark,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.glassBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            driverName.isNotEmpty
                                                ? driverName[0].toUpperCase()
                                                : 'C',
                                            style: const TextStyle(
                                              color: AppTheme.error,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          driverName,
                                          style: const TextStyle(
                                            color: Color(0xFFE8E8F0),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${monto.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: AppTheme.error,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (status == 'vencido'
                                                          ? AppTheme.error
                                                          : AppTheme.warning)
                                                      .withAlpha(30),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                color: status == 'vencido'
                                                    ? AppTheme.error
                                                    : AppTheme.warning,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          if (_pagos
                              .where(
                                (p) =>
                                    p['status'] == 'pendiente' ||
                                    p['status'] == 'vencido',
                              )
                              .isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.successContainer.withAlpha(60),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.success.withAlpha(60),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppTheme.success,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Todos los pagos al corriente',
                                    style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Fleet status
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado de la flotilla',
                            style: TextStyle(
                              color: Color(0xFFE8E8F0),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._motos.map((moto) {
                            final status =
                                moto['status'] as String? ?? 'inactiva';
                            final km = moto['kilometraje_actual'] as int? ?? 0;
                            final kmServicio =
                                moto['kilometraje_ultimo_servicio'] as int? ??
                                0;
                            final kmParaServicio =
                                moto['km_para_servicio'] as int? ?? 3000;
                            final kmRestante =
                                (kmServicio + kmParaServicio) - km;
                            final needsService = kmRestante <= 500;
                            Color statusColor;
                            switch (status) {
                              case 'activa':
                                statusColor = AppTheme.success;
                                break;
                              case 'en_servicio':
                                statusColor = AppTheme.warning;
                                break;
                              default:
                                statusColor = const Color(0xFF6B7280);
                            }
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.two_wheeler_rounded,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${moto['placa']} — ${moto['marca']} ${moto['modelo']}',
                                          style: const TextStyle(
                                            color: Color(0xFFE8E8F0),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '$km km · ${needsService ? "⚠ Servicio pronto" : "$kmRestante km para servicio"}',
                                          style: TextStyle(
                                            color: needsService
                                                ? AppTheme.warning
                                                : const Color(0xFF6B7280),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
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

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE8E8F0),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
