import 'package:flutter/material.dart';

class ContextBackground extends StatelessWidget {
  final Widget child;

  const ContextBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    // De 7:00 a 18:59 = día
    // De 19:00 a 6:59 = noche
    final bool isDay = hour >= 7 && hour < 19;

    final String backgroundImage = isDay
        ? 'assets/images/earth_day.jpg'
        : 'assets/images/earth_night.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo
        Image.asset(
          backgroundImage,
          fit: BoxFit.cover,
        ),

        // Oscurece ligeramente la imagen para que
        // balas, enemigos y HUD se distingan mejor.
        Container(
          color: Colors.black.withValues(alpha: 0.12),
        ),

        // Juego
        child,
      ],
    );
  }
}