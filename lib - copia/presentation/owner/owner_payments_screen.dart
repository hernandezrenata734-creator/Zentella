import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class OwnerPaymentsScreen extends StatefulWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  State<OwnerPaymentsScreen> createState() => _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen> {
  List<Map<String, dynamic>> _pagos = [];
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = true;
  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final client = SupabaseService.instance.client;
      final pagosRes = await client
          .from('pagos')
          .select('*, driver_profiles(user_profiles(full_name), motos(placa))')
          .order('fecha_pago', ascending: false);
      final driversRes = await client
          .from('driver_profiles')
          .select('*, user_profiles(full_name), motos(placa, id)');
      if (mounted) {
        setState(() {
          _pagos = List<Map<String, dynamic>>.from(pagosRes);
          _drivers = List<Map<String, dynamic>>.from(driversRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPagos {
    if (_filter == 'todos') return _pagos;
    return _pagos.where((p) => p['status'] == _filter).toList();
  }

  double get _totalCobrado => _pagos
      .where((p) => p['status'] == 'pagado')
      .fold(0.0, (s, p) => s + ((p['monto'] as num?)?.toDouble() ?? 0));

  double get _totalPendiente => _pagos
      .where((p) => p['status'] == 'pendiente' || p['status'] == 'vencido')
      .fold(0.0, (s, p) => s + ((p['monto'] as num?)?.toDouble() ?? 0));

  void _showRegisterPaymentDialog() {
    String? selectedDriverId;
    final montoCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    String metodo = 'efectivo';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
                const Text(
                  'Registrar Pago',
                  style: TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedDriverId,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Conductor',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                  items: _drivers.map((d) {
                    final name =
                        (d['user_profiles']
                                as Map<String, dynamic>?)?['full_name']
                            as String? ??
                        'Conductor';
                    return DropdownMenuItem(
                      value: d['id'] as String,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setModalState(() => selectedDriverId = v);
                    if (v != null) {
                      final driver = _drivers.firstWhere(
                        (d) => d['id'] == v,
                        orElse: () => {},
                      );
                      final renta =
                          (driver['renta_semanal'] as num?)?.toDouble() ?? 0;
                      montoCtrl.text = renta.toStringAsFixed(0);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto (MXN)',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: metodo,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Método de pago',
                    prefixIcon: Icon(
                      Icons.payment_outlined,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'efectivo',
                      child: Text('Efectivo'),
                    ),
                    DropdownMenuItem(
                      value: 'transferencia',
                      child: Text('Transferencia'),
                    ),
                    DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                  ],
                  onChanged: (v) =>
                      setModalState(() => metodo = v ?? 'efectivo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notasCtrl,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
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
                    onPressed: isLoading || selectedDriverId == null
                        ? null
                        : () async {
                            final monto = double.tryParse(montoCtrl.text);
                            if (monto == null || monto <= 0) return;
                            setModalState(() => isLoading = true);
                            try {
                              final driver = _drivers.firstWhere(
                                (d) => d['id'] == selectedDriverId,
                                orElse: () => {},
                              );
                              final motoId =
                                  (driver['motos']
                                          as Map<String, dynamic>?)?['id']
                                      as String?;
                              await SupabaseService.instance.client
                                  .from('pagos')
                                  .insert({
                                    'driver_id': selectedDriverId,
                                    if (motoId != null) 'moto_id': motoId,
                                    'monto': monto,
                                    'fecha_pago': DateTime.now()
                                        .toIso8601String()
                                        .substring(0, 10),
                                    'status': 'pagado',
                                    'metodo_pago': metodo,
                                    if (notasCtrl.text.isNotEmpty)
                                      'notas': notasCtrl.text,
                                    'registrado_por': AuthService.currentUserId,
                                  });
                              Navigator.of(ctx).pop();
                              await _loadData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pago registrado'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Registrar pago',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Pagos',
                    style: TextStyle(
                      color: Color(0xFFE8E8F0),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showRegisterPaymentDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Registrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Summary row
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successContainer.withAlpha(60),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.success.withAlpha(60),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cobrado',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '\$${_totalCobrado.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.success,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer.withAlpha(60),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.error.withAlpha(60),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pendiente',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '\$${_totalPendiente.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.error,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _filter == 'todos',
                    onTap: () => setState(() => _filter = 'todos'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pagados',
                    selected: _filter == 'pagado',
                    onTap: () => setState(() => _filter = 'pagado'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pendientes',
                    selected: _filter == 'pendiente',
                    onTap: () => setState(() => _filter = 'pendiente'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Vencidos',
                    selected: _filter == 'vencido',
                    onTap: () => setState(() => _filter = 'vencido'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: _filteredPagos.isEmpty
                          ? const Center(
                              child: Text(
                                'Sin pagos',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredPagos.length,
                              itemBuilder: (ctx, i) {
                                final pago = _filteredPagos[i];
                                final driverData =
                                    pago['driver_profiles']
                                        as Map<String, dynamic>?;
                                final driverName =
                                    (driverData?['user_profiles']
                                            as Map<
                                              String,
                                              dynamic
                                            >?)?['full_name']
                                        as String? ??
                                    'Conductor';
                                final placa =
                                    (driverData?['motos']
                                            as Map<String, dynamic>?)?['placa']
                                        as String? ??
                                    '';
                                final monto =
                                    (pago['monto'] as num?)?.toDouble() ?? 0;
                                final status = pago['status'] as String? ?? '';
                                final fecha =
                                    pago['fecha_pago'] as String? ?? '';
                                final metodo =
                                    pago['metodo_pago'] as String? ?? '';
                                Color statusColor;
                                IconData statusIcon;
                                switch (status) {
                                  case 'pagado':
                                    statusColor = AppTheme.success;
                                    statusIcon =
                                        Icons.check_circle_outline_rounded;
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
                                    border: Border.all(
                                      color: AppTheme.glassBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              driverName,
                                              style: const TextStyle(
                                                color: Color(0xFFE8E8F0),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '$fecha · $metodo${placa.isNotEmpty ? ' · $placa' : ''}',
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withAlpha(60)
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary.withAlpha(120)
                : AppTheme.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primaryLight : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
