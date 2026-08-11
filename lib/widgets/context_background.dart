import 'package:flutter/material.dart';

class ContextBackground extends StatelessWidget {
  final Widget child;

  const ContextBackground({
    super.key,
    required this.child,
  });

  static bool get isDay {
    final hour = DateTime.now().hour;
    return hour >= 7 && hour < 19;
  }

  @override
  Widget build(BuildContext context) {
    final day = isDay;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;

        final starWidth = (width - 24).clamp(1.0, double.infinity).toDouble();
        final starHeight = (height - 24).clamp(1.0, double.infinity).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: day
                      ? const [
                          Color(0xFF2C7BE5),
                          Color(0xFF6FB6FF),
                          Color(0xFFBBD9FF),
                        ]
                      : const [
                          Color(0xFF050816),
                          Color(0xFF101B3A),
                          Color(0xFF1E2B52),
                        ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 34,
              child: Icon(
                day ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 70,
                color: day ? Colors.amberAccent : Colors.white70,
              ),
            ),
            if (!day)
              ...List.generate(
                24,
                (index) {
                  final left = 16.0 + ((index * 97.0) % starWidth);
                  final top = 18.0 + ((index * 53.0) % starHeight);
                  return Positioned(
                    left: left,
                    top: top,
                    child: const Icon(
                      Icons.circle,
                      size: 2.8,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            child,
          ],
        );
      },
    );
  }
}
