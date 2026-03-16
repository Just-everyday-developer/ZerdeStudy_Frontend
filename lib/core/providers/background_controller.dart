import 'package:flutter/material.dart';

class BackgroundController extends ChangeNotifier {
  AnimationController? _controller;

  void initialize(TickerProvider vsync) {
    if (_controller != null) {
      return;
    }

    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 30),
    )..repeat();

    _controller!.addListener(notifyListeners);
  }

  double get value => _controller?.value ?? 0;

  void shutdown() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    shutdown();
    super.dispose();
  }
}
