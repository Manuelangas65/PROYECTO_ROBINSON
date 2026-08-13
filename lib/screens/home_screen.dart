import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'scores_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ======================================================
          // FONDO ESPACIAL
          // ======================================================

          Image.asset(
            'assets/images/menu_space.jpg',
            fit: BoxFit.cover,
          ),


          // ======================================================
          // CAPA OSCURA
          // ======================================================

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),


          // ======================================================
          // CONTENIDO
          // ======================================================

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // TÍTULO
                  const Text(
                    'GALAGA',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          blurRadius: 14,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'SPACE ATTACK',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 48),


                  // =================================================
                  // JUGAR
                  // =================================================

                  SizedBox(
                    width: 230,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.rocket_launch_rounded,
                      ),
                      label: const Text(
                        'JUGAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),


                  // =================================================
                  // PUNTUACIONES
                  // =================================================

                  SizedBox(
                    width: 230,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ScoresScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 2,
                        ),
                      ),
                      icon: const Icon(
                        Icons.leaderboard_rounded,
                      ),
                      label: const Text(
                        'PUNTUACIONES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}