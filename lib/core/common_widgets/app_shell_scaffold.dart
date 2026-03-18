import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme_colors.dart';

class AppShellScaffold extends StatefulWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
    required this.navigatorKeys,
  });

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  @override
  State<AppShellScaffold> createState() => _AppShellScaffoldState();
}

class _AppShellScaffoldState extends State<AppShellScaffold> {
  final List<int> _branchHistory = <int>[];

  Future<bool> _handleBack() async {
    final navigator = widget.navigatorKeys[widget.navigationShell.currentIndex]
        .currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }

    if (_branchHistory.isNotEmpty) {
      final previousIndex = _branchHistory.removeLast();
      widget.navigationShell.goBranch(previousIndex);
      return false;
    }

    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
    }
    return false;
  }

  void _onDestinationSelected(int index) {
    final currentIndex = widget.navigationShell.currentIndex;
    if (index == currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    _branchHistory.remove(index);
    _branchHistory.add(currentIndex);
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.space_dashboard_outlined),
              selectedIcon: const Icon(Icons.space_dashboard_rounded),
              label: context.l10n.text('tab_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_tree_outlined),
              selectedIcon: const Icon(Icons.account_tree_rounded),
              label: context.l10n.text('tab_tree'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: context.l10n.text('tab_learn'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.smart_toy_outlined),
              selectedIcon: const Icon(Icons.smart_toy_rounded),
              label: context.l10n.text('tab_ai'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: context.l10n.text('tab_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
