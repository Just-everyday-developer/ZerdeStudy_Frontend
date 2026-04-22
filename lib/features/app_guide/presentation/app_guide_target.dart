import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appGuideTargetRegistryProvider = Provider<AppGuideTargetRegistry>((ref) {
  return AppGuideTargetRegistry();
});

class AppGuideTargetRegistry {
  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  GlobalKey keyFor(String id) {
    return _keys.putIfAbsent(
      id,
      () => GlobalKey(debugLabel: 'app-guide-target-$id'),
    );
  }

  Rect? globalRectFor(String id) {
    final context = _keys[id]?.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return null;
    }
    if (!renderObject.hasSize || renderObject.size.isEmpty) {
      return null;
    }
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }
}

class AppGuideTarget extends ConsumerWidget {
  const AppGuideTarget({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.read(appGuideTargetRegistryProvider).keyFor(id);
    return KeyedSubtree(key: key, child: child);
  }
}
