import 'package:flutter/material.dart';
import '../../../../main.dart'; // импорт глобального контроллера
import 'InfiniteTechPainter.dart';

class AuthBackgroundWrapper extends StatefulWidget {
  final Widget child;
  const AuthBackgroundWrapper({super.key, required this.child});

  @override
  State<AuthBackgroundWrapper> createState() => _AuthBackgroundWrapperState();
}

class _AuthBackgroundWrapperState extends State<AuthBackgroundWrapper> {
  Offset _pointerOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Или AppColors.background
      body: MouseRegion(
        onHover: (event) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _pointerOffset = Offset(
              event.position.dx - (size.width / 2),
              event.position.dy - (size.height / 2),
            );
          });
        },
        child: Stack(
          children: [
            // Фон который слушает глобальный контроллер
            Positioned.fill(
              child: ListenableBuilder(
                listenable: backgroundController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: InfiniteTechPainter(
                      animationValue: backgroundController.value,
                      pointerOffset: _pointerOffset,
                    ),
                  );
                },
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}