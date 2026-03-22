import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../../app/state/app_locale.dart';
import '../../app/state/demo_app_controller.dart';
import 'app_settings_panel.dart';
import '../localization/app_localizations.dart';
import '../providers/course_search_focus_provider.dart';
import '../theme/app_theme_colors.dart';

class AppShellScaffold extends ConsumerStatefulWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
    required this.navigatorKeys,
  });

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  @override
  ConsumerState<AppShellScaffold> createState() => _AppShellScaffoldState();
}

class _AppShellScaffoldState extends ConsumerState<AppShellScaffold> {
  final List<int> _branchHistory = <int>[];
  final FocusNode _shellFocusNode = FocusNode(debugLabel: 'app-shell-shortcuts');

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleHardwareShortcut);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareShortcut);
    _shellFocusNode.dispose();
    super.dispose();
  }

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

  void _requestSearchFocus() {
    ref.read(courseSearchFocusRequestProvider.notifier).ping();
  }

  bool _hasEditableTextFocus() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }
    return focusedContext.widget is EditableText;
  }

  void _selectAdjacentBranch(int delta) {
    final destinationsCount = 5;
    final currentIndex = widget.navigationShell.currentIndex;
    final nextIndex = (currentIndex + delta + destinationsCount) % destinationsCount;
    _onDestinationSelected(nextIndex);
  }

  KeyEventResult _handleShellKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final ctrlPressed = HardwareKeyboard.instance.isControlPressed;
    final altPressed = HardwareKeyboard.instance.isAltPressed;
    final shiftPressed = HardwareKeyboard.instance.isShiftPressed;

    if (altPressed && !ctrlPressed) {
      if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyZ) {
        _handleBack();
        return KeyEventResult.handled;
      }

      final directIndex = switch (key) {
        LogicalKeyboardKey.digit1 || LogicalKeyboardKey.numpad1 => 0,
        LogicalKeyboardKey.digit2 || LogicalKeyboardKey.numpad2 => 1,
        LogicalKeyboardKey.digit3 || LogicalKeyboardKey.numpad3 => 2,
        LogicalKeyboardKey.digit4 || LogicalKeyboardKey.numpad4 => 3,
        LogicalKeyboardKey.digit5 || LogicalKeyboardKey.numpad5 => 4,
        _ => null,
      };
      if (directIndex != null) {
        _onDestinationSelected(directIndex);
        return KeyEventResult.handled;
      }
    }

    if (ctrlPressed && key == LogicalKeyboardKey.tab) {
      _selectAdjacentBranch(shiftPressed ? -1 : 1);
      return KeyEventResult.handled;
    }

    if (ctrlPressed && key == LogicalKeyboardKey.keyK) {
      _onDestinationSelected(2);
      _requestSearchFocus();
      return KeyEventResult.handled;
    }

    if (ctrlPressed && key == LogicalKeyboardKey.keyL) {
      _onDestinationSelected(2);
      return KeyEventResult.handled;
    }

    if (ctrlPressed && key == LogicalKeyboardKey.keyT) {
      _onDestinationSelected(1);
      return KeyEventResult.handled;
    }

    if (!ctrlPressed && !altPressed && !_hasEditableTextFocus()) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        _selectAdjacentBranch(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        _selectAdjacentBranch(1);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  bool _handleHardwareShortcut(KeyEvent event) {
    if (!mounted) {
      return false;
    }
    return _handleShellKeyEvent(event) == KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final state = ref.watch(demoAppControllerProvider);
    final destinations = <_ShellDestination>[
      _ShellDestination(
        label: l10n.text('tab_home'),
        route: AppRoutes.home,
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
      ),
      _ShellDestination(
        label: l10n.text('tab_tree'),
        route: AppRoutes.tree,
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree_rounded,
      ),
      _ShellDestination(
        label: l10n.text('tab_learn'),
        route: AppRoutes.learn,
        icon: Icons.auto_stories_outlined,
        selectedIcon: Icons.auto_stories_rounded,
      ),
      _ShellDestination(
        label: l10n.text('tab_ai'),
        route: AppRoutes.ai,
        icon: Icons.smart_toy_outlined,
        selectedIcon: Icons.smart_toy_rounded,
      ),
      _ShellDestination(
        label: l10n.text('tab_profile'),
        route: AppRoutes.profile,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBack();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final currentNavigator =
              widget.navigatorKeys[widget.navigationShell.currentIndex]
                  .currentState;
          final canGoBack = (currentNavigator?.canPop() ?? false) ||
              _branchHistory.isNotEmpty ||
              widget.navigationShell.currentIndex != 0;
          final shellBody = compact
              ? widget.navigationShell
              : Column(
                  children: [
                    _DesktopShellBar(
                      destinations: destinations,
                      currentIndex: widget.navigationShell.currentIndex,
                      currentUserName: state.user?.name ?? 'Talgat',
                      onDestinationSelected: _onDestinationSelected,
                      onBackTap: () => _handleBack(),
                      onSearchTap: () {
                        _onDestinationSelected(2);
                        _requestSearchFocus();
                      },
                      onProfileTap: () => context.push(AppRoutes.profilePreview),
                      onSettingsTap: () => showAppSettingsPanel(context),
                      onLocaleSelected: ref
                          .read(demoAppControllerProvider.notifier)
                          .changeLocale,
                      currentLocale: state.locale,
                      canGoBack: canGoBack,
                    ),
                    Divider(height: 1, color: colors.divider),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: widget.navigationShell,
                      ),
                    ),
                  ],
                );

          return Focus(
            focusNode: _shellFocusNode,
            autofocus: true,
            child: Scaffold(
              backgroundColor: colors.background,
              body: shellBody,
              bottomNavigationBar: compact
                  ? NavigationBar(
                      selectedIndex: widget.navigationShell.currentIndex,
                      onDestinationSelected: _onDestinationSelected,
                      destinations: destinations
                          .map(
                            (destination) => NavigationDestination(
                              icon: Icon(destination.icon),
                              selectedIcon: Icon(destination.selectedIcon),
                              label: destination.label,
                            ),
                          )
                          .toList(growable: false),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _DesktopShellBar extends StatelessWidget {
  const _DesktopShellBar({
    required this.destinations,
    required this.currentIndex,
    required this.currentUserName,
    required this.onDestinationSelected,
    required this.onBackTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onLocaleSelected,
    required this.currentLocale,
    required this.canGoBack,
  });

  final List<_ShellDestination> destinations;
  final int currentIndex;
  final String currentUserName;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onBackTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final ValueChanged<AppLocale> onLocaleSelected;
  final AppLocale currentLocale;
  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
        child: Row(
          children: [
            if (canGoBack) ...[
              IconButton(
                onPressed: onBackTap,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.textPrimary,
                ),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List<Widget>.generate(
                  destinations.length,
                  (index) => _DesktopNavChip(
                    destination: destinations[index],
                    selected: currentIndex == index,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            IconButton(
              onPressed: onSearchTap,
              icon: Icon(Icons.search_rounded, color: colors.textPrimary),
              tooltip: context.l10n.text('search_courses'),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<AppLocale>(
              tooltip: context.l10n.text('locale'),
              initialValue: currentLocale,
              offset: const Offset(0, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: colors.surface,
              onSelected: onLocaleSelected,
              itemBuilder: (context) {
                return AppLocale.values
                    .map(
                      (locale) => PopupMenuItem<AppLocale>(
                        value: locale,
                        child: Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              size: 18,
                              color: locale == currentLocale
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              locale.label,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: locale == currentLocale
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false);
              },
              child: Row(
                children: [
                  Icon(Icons.language_rounded, color: colors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    currentLocale.label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onSettingsTap,
              tooltip: context.l10n.text('settings'),
              icon: Icon(Icons.settings_rounded, color: colors.textPrimary),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(18),
              child: Hero(
                tag: 'shell-profile-avatar',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary.withValues(alpha: 0.18),
                  child: Text(
                    currentUserName.isEmpty
                        ? 'Z'
                        : currentUserName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopNavChip extends StatelessWidget {
  const _DesktopNavChip({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? colors.primary.withValues(alpha: 0.14)
              : colors.surfaceSoft,
          border: Border.all(
            color: selected ? colors.primary : colors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: 18,
              color: selected ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              destination.label,
              style: TextStyle(
                color: selected ? colors.primary : colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
}
