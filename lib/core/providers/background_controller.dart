import 'package:flutter/material.dart';

class BackgroundController extends ChangeNotifier {
  late AnimationController _controller;

  void initialize(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Подписываемся на обновление, чтобы уведомлять слушателей
    _controller.addListener(() {
      notifyListeners();
    });
  }

  double get value => _controller.value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}