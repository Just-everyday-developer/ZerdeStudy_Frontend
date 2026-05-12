import 'package:flutter/material.dart';

class BubbleProgressBar extends StatefulWidget {
  const BubbleProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.bubbleText,
    this.height = 10,
  });

  final double value;
  final Color color;
  final Color backgroundColor;
  final String? bubbleText;
  final double height;

  @override
  State<BubbleProgressBar> createState() => _BubbleProgressBarState();
}

class _BubbleProgressBarState extends State<BubbleProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(BubbleProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final clampedVal = widget.value.clamp(0.0, 1.0);
            final currentProgress = clampedVal * _animation.value;
            final bubbleX = currentProgress * totalWidth;
            final percentText = widget.bubbleText ?? '${(clampedVal * 100).round()}%';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Bubble with bottom arrow
                SizedBox(
                  height: 32,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: (bubbleX - 24).clamp(0.0, (totalWidth - 48).clamp(0.0, totalWidth)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.color,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                percentText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            // Small triangle arrow pointing down
                            CustomPaint(
                              size: const Size(10, 5),
                              painter: _TrianglePainter(color: widget.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Progress Bar
                Container(
                  height: widget.height,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: totalWidth * currentProgress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              Color.lerp(widget.color, Colors.white, 0.25) ?? widget.color,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}
