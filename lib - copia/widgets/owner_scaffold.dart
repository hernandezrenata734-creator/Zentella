import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OwnerScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F0F1A),
      body: navigationShell,
      bottomNavigationBar: _OwnerNavigation(navigationShell: navigationShell),
    );
  }
}

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _OwnerNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _OwnerNavigation({required this.navigationShell});

  @override
  State<_OwnerNavigation> createState() => _OwnerNavigationState();
}

class _OwnerNavigationState extends State<_OwnerNavigation> {
  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Panel',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _TabSpec(
      label: 'Mapa',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _TabSpec(
      label: 'Conductores',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    _TabSpec(
      label: 'Pagos',
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments_rounded,
    ),
  ];

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64 + bottomPadding,
          decoration: const BoxDecoration(
            color: Color(0x1A1A1A2E),
            border: Border(
              top: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
            ),
          ),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7C3AED).withAlpha(64)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF7C3AED).withAlpha(128),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? tab.selectedIcon : tab.icon,
                              key: ValueKey(isSelected),
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFF6B7280),
                            ),
                            child: Text(tab.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
