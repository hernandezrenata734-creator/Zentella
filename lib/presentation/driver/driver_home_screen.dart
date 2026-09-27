import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _driverProfile;
  List<Map<String, dynamic>> _pagos = [];
  List<Map<String, dynamic>> _kmLogs = [];
  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  int _selectedTab = 0;

  final _kmInicioController = TextEditingController();
  final _kmFinController = TextEditingController();
  final _kmNotasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _kmInicioController.dispose();
    _kmFinController.dispose();
    _kmNotasController.dispose();
    super.dispose();
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

      final driverRes = await client
          .from('driver_profiles')
          .select('*, motos(*)')
          .eq('id', userId)
          .maybeSingle();

      final pagosRes = await client
          .from('pagos')
          .select()
          .eq('driver_id', userId)
          .order('fecha_pago', ascending: false)
          .limit(10);

      final kmRes = await client
          .from('km_logs')
          .select()
          .eq('driver_id', userId)
          .order('fecha', ascending: false)
          .limit(7);

      if (mounted) {
        setState(() {
          _profile = profileRes;
          _driverProfile = driverRes;
          _pagos = List<Map<String, dynamic>>.from(pagosRes);
          _kmLogs = List<Map<String, dynamic>>.from(kmRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (_driverProfile == null) return;
    setState(() => _isUpdatingStatus = true);
    try {
      final client = SupabaseService.instance.client;
      final currentStatus = _driverProfile!['status'] as String? ?? 'inactivo';
      final newStatus = currentStatus == 'activo' ? 'inactivo' : 'activo';
      await client
          .from('driver_profiles')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', AuthService.currentUserId!);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar estado')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _logKilometers() async {
    final kmInicio = int.tryParse(_kmInicioController.text);
    final kmFin = int.tryParse(_kmFinController.text);
    if (kmInicio == null || kmFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa kilómetros válidos')),
      );
      return;
    }
    if (kmFin <= kmInicio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El km final debe ser mayor al inicial')),
      );
      return;
    }
    final motoId = _driverProfile?['moto_id'] as String?;
    if (motoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes una moto asignada')),
      );
      return;
    }
    try {
      final client = SupabaseService.instance.client;
      await client.from('km_logs').insert({
        'driver_id': AuthService.currentUserId,
        'moto_id': motoId,
        'km_inicio': kmInicio,
        'km_fin': kmFin,
        'fecha': DateTime.now().toIso8601String().substring(0, 10),
        if (_kmNotasController.text.isNotEmpty)
          'notas': _kmNotasController.text,
      });
      _kmInicioController.clear();
      _kmFinController.clear();
      _kmNotasController.clear();
      Navigator.of(context).pop();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kilómetros registrados'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar kilómetros')),
        );
      }
    }
  }

  void _showKmDialog() {
    final moto = _driverProfile?['motos'] as Map<String, dynamic>?;
    final currentKm = moto?['kilometraje_actual'] as int? ?? 0;
    _kmInicioController.text = currentKm.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Registrar Kilómetros',
                    style: TextStyle(
                      color: Color(0xFFE8E8F0),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kmInicioController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Color(0xFFE8E8F0),
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'KM Inicio',
                        prefixIcon: Icon(
                          Icons.start,
                          color: Color(0xFF6B7280),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _kmFinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Color(0xFFE8E8F0),
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'KM Final',
                        prefixIcon: Icon(
                          Icons.flag_outlined,
                          color: Color(0xFF6B7280),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _kmNotasController,
                style: const TextStyle(color: Color(0xFFE8E8F0), fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(
                    Icons.notes_outlined,
                    color: Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _logKilometers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final name = _profile?['full_name'] as String? ?? 'Conductor';
    final status = _driverProfile?['status'] as String? ?? 'inactivo';
    final isActive = status == 'activo';
    final moto = _driverProfile?['motos'] as Map<String, dynamic>?;
    final rentaSemanal =
        (_driverProfile?['renta_semanal'] as num?)?.toDouble() ?? 0;
    final diaPago = _driverProfile?['dia_pago'] as int? ?? 1;

    // Calculate debt
    double totalDeuda = 0;
    for (final p in _pagos) {
      if (p['status'] == 'pendiente' || p['status'] == 'vencido') {
        totalDeuda += (p['monto'] as num?)?.toDouble() ?? 0;
      }
    }

    final diasSemana = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final diaNombre = diaPago >= 1 && diaPago <= 7
        ? diasSemana[diaPago]
        : 'Lunes';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isActive ? AppTheme.secondary : const Color(0xFF6B7280))
                        .withAlpha(50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
                              'Hola, ${name.split(' ').first}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
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
                      IconButton(
                        onPressed: () async {
                          await AuthService.signOut();
                          if (mounted) context.go('/login');
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Inicio',
                          icon: Icons.home_outlined,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        _TabButton(
                          label: 'Pagos',
                          icon: Icons.payments_outlined,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                        _TabButton(
                          label: 'Kilómetros',
                          icon: Icons.speed_outlined,
                          isSelected: _selectedTab == 2,
                          onTap: () => setState(() => _selectedTab = 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceDark,
                    child: _selectedTab == 0
                        ? _buildHomeTab(
                            isActive,
                            moto,
                            rentaSemanal,
                            diaNombre,
                            totalDeuda,
                          )
                        : _selectedTab == 1
                        ? _buildPaymentsTab()
                        : _buildKmTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 2
          ? FloatingActionButton.extended(
              onPressed: _showKmDialog,
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Registrar KM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHomeTab(
    bool isActive,
    Map<String, dynamic>? moto,
    double rentaSemanal,
    String diaNombre,
    double totalDeuda,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        // Status toggle card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [const Color(0xFF065F46), const Color(0xFF064E3B)]
                  : [const Color(0xFF1F2937), const Color(0xFF111827)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppTheme.secondary.withAlpha(80)
                  : const Color(0xFF374151),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (isActive
                                  ? AppTheme.secondary
                                  : const Color(0xFF6B7280))
                              .withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isActive
                          ? AppTheme.secondary
                          : const Color(0xFF6B7280),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: isActive
                                ? AppTheme.secondary
                                : const Color(0xFF9CA3AF),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          isActive
                              ? 'Estás trabajando ahora'
                              : 'No estás en servicio',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isUpdatingStatus
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.secondary,
                          ),
                        )
                      : Switch(
                          value: isActive,
                          onChanged: (_) => _toggleStatus(),
                          activeThumbColor: AppTheme.secondary,
                          activeTrackColor: AppTheme.secondary.withAlpha(60),
                          inactiveThumbColor: const Color(0xFF6B7280),
                          inactiveTrackColor: const Color(0xFF374151),
                        ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Payment info
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.calendar_today_outlined,
                iconColor: AppTheme.info,
                label: 'Día de pago',
                value: diaNombre,
                subtitle: 'Cada semana',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.payments_outlined,
                iconColor: AppTheme.warning,
                label: 'Renta semanal',
                value: '\$${rentaSemanal.toStringAsFixed(0)}',
                subtitle: 'MXN',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Debt card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: totalDeuda > 0
                ? AppTheme.errorContainer.withAlpha(80)
                : AppTheme.successContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: totalDeuda > 0
                  ? AppTheme.error.withAlpha(60)
                  : AppTheme.success.withAlpha(60),
            ),
          ),
          child: Row(
            children: [
              Icon(
                totalDeuda > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                color: totalDeuda > 0 ? AppTheme.error : AppTheme.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalDeuda > 0 ? 'Adeudo pendiente' : 'Sin adeudos',
                      style: TextStyle(
                        color: totalDeuda > 0
                            ? AppTheme.error
                            : AppTheme.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (totalDeuda > 0)
                      Text(
                        'Debes \$${totalDeuda.toStringAsFixed(0)} MXN',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (totalDeuda > 0)
                Text(
                  '\$${totalDeuda.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Moto info
        if (moto != null) ...[
          const Text(
            'Mi Moto',
            style: TextStyle(
              color: Color(0xFFE8E8F0),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${moto['marca'] ?? ''} ${moto['modelo'] ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFFE8E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Placa: ${moto['placa'] ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${moto['kilometraje_actual'] ?? 0} km',
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Odómetro',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        if (_pagos.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Sin historial de pagos',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ..._pagos.map((pago) {
            final status = pago['status'] as String? ?? 'pendiente';
            final monto = (pago['monto'] as num?)?.toDouble() ?? 0;
            final fecha = pago['fecha_pago'] as String? ?? '';
            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'pagado':
                statusColor = AppTheme.success;
                statusIcon = Icons.check_circle_outline_rounded;
                break;
              case 'vencido':
                statusColor = AppTheme.error;
                statusIcon = Icons.error_outline_rounded;
                break;
              default:
                statusColor = AppTheme.warning;
                statusIcon = Icons.schedule_rounded;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Renta semanal',
                          style: const TextStyle(
                            color: Color(0xFFE8E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          fecha,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${monto.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
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
                ],
              ),
            );
          }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildKmTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        if (_kmLogs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Sin registros de kilómetros',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ..._kmLogs.map((log) {
            final kmRecorridos = log['km_recorridos'] as int? ?? 0;
            final fecha = log['fecha'] as String? ?? '';
            final kmFin = log['km_fin'] as int? ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: AppTheme.primaryLight,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fecha,
                          style: const TextStyle(
                            color: Color(0xFFE8E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Odómetro: $kmFin km',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+$kmRecorridos km',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withAlpha(60)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppTheme.primaryLight
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryLight
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE8E8F0),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
