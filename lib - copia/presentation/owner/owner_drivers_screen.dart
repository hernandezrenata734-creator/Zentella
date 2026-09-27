import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class OwnerDriversScreen extends StatefulWidget {
  const OwnerDriversScreen({super.key});

  @override
  State<OwnerDriversScreen> createState() => _OwnerDriversScreenState();
}

class _OwnerDriversScreenState extends State<OwnerDriversScreen> {
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = true;
  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    try {
      final client = SupabaseService.instance.client;
      var query = client
          .from('driver_profiles')
          .select('*, user_profiles(*), motos(*)');
      final res = await query.order('created_at');
      if (mounted) {
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredDrivers {
    if (_filter == 'todos') return _drivers;
    if (_filter == 'lista_negra') {
      return _drivers.where((d) => d['en_lista_negra'] == true).toList();
    }
    return _drivers.where((d) => d['status'] == _filter).toList();
  }

  void _showAddDriverDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final rentaCtrl = TextEditingController();
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
                  'Agregar Conductor',
                  style: TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rentaCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Color(0xFFE8E8F0),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Renta semanal (MXN)',
                    prefixIcon: Icon(
                      Icons.attach_money,
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                              return;
                            }
                            setModalState(() => isLoading = true);
                            try {
                              final res = await AuthService.signUp(
                                email: emailCtrl.text.trim(),
                                password: 'moto2024',
                                fullName: nameCtrl.text.trim(),
                                role: 'conductor',
                                phone: phoneCtrl.text.trim(),
                              );
                              if (res.user != null) {
                                final renta =
                                    double.tryParse(rentaCtrl.text) ?? 0;
                                if (renta > 0) {
                                  await SupabaseService.instance.client
                                      .from('driver_profiles')
                                      .update({'renta_semanal': renta})
                                      .eq('id', res.user!.id);
                                }
                                Navigator.of(ctx).pop();
                                await _loadDrivers();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Conductor agregado. Contraseña: moto2024',
                                      ),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setModalState(() => isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
                            'Crear conductor',
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

  void _showDriverDetail(Map<String, dynamic> driver) {
    final profile = driver['user_profiles'] as Map<String, dynamic>?;
    final moto = driver['motos'] as Map<String, dynamic>?;
    final name = profile?['full_name'] as String? ?? 'Conductor';
    final email = profile?['email'] as String? ?? '';
    final phone = profile?['phone'] as String? ?? '';
    final status = driver['status'] as String? ?? 'inactivo';
    final renta = (driver['renta_semanal'] as num?)?.toDouble() ?? 0;
    final calificacion = (driver['calificacion'] as num?)?.toDouble() ?? 0;
    final enListaNegra = driver['en_lista_negra'] as bool? ?? false;
    final contratoStatus = driver['contrato_status'] as String? ?? '';
    final contratoVence = driver['contrato_vence'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: enListaNegra
                            ? [AppTheme.error, AppTheme.errorContainer]
                            : [AppTheme.primary, AppTheme.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFFE8E8F0),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                        if (enListaNegra)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LISTA NEGRA',
                              style: TextStyle(
                                color: AppTheme.error,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: phone.isEmpty ? 'No registrado' : phone,
              ),
              _DetailRow(
                icon: Icons.two_wheeler_rounded,
                label: 'Moto asignada',
                value: moto != null
                    ? '${moto['placa']} — ${moto['marca']} ${moto['modelo']}'
                    : 'Sin moto',
              ),
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Renta semanal',
                value: '\$${renta.toStringAsFixed(0)} MXN',
              ),
              _DetailRow(
                icon: Icons.star_outline_rounded,
                label: 'Calificación',
                value: '${calificacion.toStringAsFixed(1)} / 5.0',
              ),
              _DetailRow(
                icon: Icons.circle,
                label: 'Estado',
                value: status.toUpperCase(),
              ),
              if (contratoStatus.isNotEmpty)
                _DetailRow(
                  icon: Icons.description_outlined,
                  label: 'Contrato',
                  value: '$contratoStatus — vence: $contratoVence',
                ),
              const SizedBox(height: 20),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await SupabaseService.instance.client
                            .from('driver_profiles')
                            .update({'en_lista_negra': !enListaNegra})
                            .eq('id', driver['id']);
                        await _loadDrivers();
                      },
                      icon: Icon(
                        enListaNegra
                            ? Icons.remove_circle_outline
                            : Icons.block_rounded,
                        size: 16,
                      ),
                      label: Text(
                        enListaNegra ? 'Quitar de lista' : 'Lista negra',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error.withAlpha(60)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                    'Conductores',
                    style: TextStyle(
                      color: Color(0xFFE8E8F0),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showAddDriverDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Agregar',
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
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    value: 'todos',
                    selected: _filter == 'todos',
                    onTap: () => setState(() => _filter = 'todos'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Activos',
                    value: 'activo',
                    selected: _filter == 'activo',
                    onTap: () => setState(() => _filter = 'activo'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Inactivos',
                    value: 'inactivo',
                    selected: _filter == 'inactivo',
                    onTap: () => setState(() => _filter = 'inactivo'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Lista negra',
                    value: 'lista_negra',
                    selected: _filter == 'lista_negra',
                    onTap: () => setState(() => _filter = 'lista_negra'),
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
                      onRefresh: _loadDrivers,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: _filteredDrivers.isEmpty
                          ? const Center(
                              child: Text(
                                'Sin conductores',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredDrivers.length,
                              itemBuilder: (ctx, i) {
                                final driver = _filteredDrivers[i];
                                final profile =
                                    driver['user_profiles']
                                        as Map<String, dynamic>?;
                                final moto =
                                    driver['motos'] as Map<String, dynamic>?;
                                final name =
                                    profile?['full_name'] as String? ??
                                    'Conductor';
                                final status =
                                    driver['status'] as String? ?? 'inactivo';
                                final renta =
                                    (driver['renta_semanal'] as num?)
                                        ?.toDouble() ??
                                    0;
                                final calificacion =
                                    (driver['calificacion'] as num?)
                                        ?.toDouble() ??
                                    0;
                                final enListaNegra =
                                    driver['en_lista_negra'] as bool? ?? false;
                                Color statusColor;
                                switch (status) {
                                  case 'activo':
                                    statusColor = AppTheme.success;
                                    break;
                                  case 'suspendido':
                                    statusColor = AppTheme.error;
                                    break;
                                  default:
                                    statusColor = const Color(0xFF6B7280);
                                }
                                return GestureDetector(
                                  onTap: () => _showDriverDetail(driver),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceDark,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: enListaNegra
                                            ? AppTheme.error.withAlpha(60)
                                            : AppTheme.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: enListaNegra
                                                ? AppTheme.error.withAlpha(30)
                                                : AppTheme.primary.withAlpha(
                                                    30,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              name.isNotEmpty
                                                  ? name[0].toUpperCase()
                                                  : 'C',
                                              style: TextStyle(
                                                color: enListaNegra
                                                    ? AppTheme.error
                                                    : AppTheme.primaryLight,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFE8E8F0,
                                                        ),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (enListaNegra)
                                                    const Icon(
                                                      Icons.block_rounded,
                                                      color: AppTheme.error,
                                                      size: 14,
                                                    ),
                                                ],
                                              ),
                                              Text(
                                                moto != null
                                                    ? '${moto['placa']} · \$${renta.toStringAsFixed(0)}/sem'
                                                    : 'Sin moto asignada',
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
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withAlpha(
                                                  30,
                                                ),
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
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  color: Color(0xFFF59E0B),
                                                  size: 12,
                                                ),
                                                Text(
                                                  calificacion.toStringAsFixed(
                                                    1,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Color(0xFFF59E0B),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B7280), size: 16),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE8E8F0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
