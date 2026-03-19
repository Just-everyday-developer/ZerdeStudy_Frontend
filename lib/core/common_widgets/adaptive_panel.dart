import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_theme_colors.dart';

Future<T?> showAdaptivePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  double wideMaxWidth = 560,
}) {
  if (context.isCompactLayout) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      builder: (context) {
        return _AdaptivePanelFrame(
          compact: true,
          maxWidth: wideMaxWidth,
          child: builder(context),
        );
      },
    );
  }

  return showDialog<T>(
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: _AdaptivePanelFrame(
          compact: false,
          maxWidth: wideMaxWidth,
          child: builder(context),
        ),
      );
    },
  );
}

class AdaptivePanelHandle extends StatelessWidget {
  const AdaptivePanelHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: colors.divider,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _AdaptivePanelFrame extends StatelessWidget {
  const _AdaptivePanelFrame({
    required this.compact,
    required this.maxWidth,
    required this.child,
  });

  final bool compact;
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(compact ? 28 : 30),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );

    if (compact) {
      return content;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: content,
    );
  }
}
