import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// V3 Liquid Glass BottomNav — BackdropFilter blur + frosted surface + animated pill — LOCKED

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedVisualIndex = 0;
  late AnimationController _pillController;
  late Animation<double> _pillAnimation;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Panel',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Mapa',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Conductores',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      branchIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pillAnimation = CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    if (tab.branchIndex == null) return; // stub tab — silent ignore

    if (visualIndex != _selectedVisualIndex) {
      setState(() => _selectedVisualIndex = visualIndex);
      _pillController.forward(from: 0);
    }

    widget.navigationShell.goBranch(
      tab.branchIndex!,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64 + bottomPadding,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withAlpha(191),
              border: const Border(
                top: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
              ),
            ),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = _selectedVisualIndex == index;
                final isStub = tab.branchIndex == null;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      opacity: isStub ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 64,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7C3AED).withAlpha(64)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(
                                      0xFF7C3AED,
                                    ).withAlpha(128),
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
                                  size: 22,
                                  color: isSelected
                                      ? const Color(0xFFA78BFA)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
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
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
