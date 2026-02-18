import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';

class AnimatedWelcomeText extends StatefulWidget {
  final String text;
  const AnimatedWelcomeText({super.key, required this.text});

  @override
  State<AnimatedWelcomeText> createState() => _AnimatedWelcomeTextState();
}

class _AnimatedWelcomeTextState extends State<AnimatedWelcomeText> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _loop();
  }

  Future<void> _loop() async {
    while (mounted) {
      // держим видимым
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _visible = false);

      // время на исчезновение
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _visible = true);

      // время на появление
      await Future.delayed(const Duration(milliseconds: 900));
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.03), // чуть вниз при исчезновении
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40 * u,
            height: 1.08,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
