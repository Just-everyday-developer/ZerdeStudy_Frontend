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

  void register(String id, GlobalKey key) {
    _keys[id] = key;
  }

  void unregister(String id, GlobalKey key) {
    if (_keys[id] == key) {
      _keys.remove(id);
    }
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

class AppGuideTarget extends ConsumerStatefulWidget {
  const AppGuideTarget({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  ConsumerState<AppGuideTarget> createState() => _AppGuideTargetState();
}

class _AppGuideTargetState extends ConsumerState<AppGuideTarget> {
  late final GlobalKey _key;
  late final AppGuideTargetRegistry _registry;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey(debugLabel: 'app-guide-target-${widget.id}-${identityHashCode(this)}');
    _registry = ref.read(appGuideTargetRegistryProvider);
    _registry.register(widget.id, _key);
  }

  @override
  void didUpdateWidget(AppGuideTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _registry.unregister(oldWidget.id, _key);
      _registry.register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    _registry.unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
