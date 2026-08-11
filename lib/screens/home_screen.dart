import 'package:flutter/material.dart';

import '../widgets/context_background.dart';
import 'game_screen.dart';
import 'scores_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDay = ContextBackground.isDay;

    return Scaffold(
      body: ContextBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.rocket_launch_rounded,
                              size: 90,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'GALAXY GYRO',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isDay
                                  ? 'Modo diurno detectado automáticamente'
                                  : 'Modo nocturno detectado automáticamente',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'JUGAR',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ScoresScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.emoji_events_rounded),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('PUNTUACIONES'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () => _showHowToPlay(context),
                                icon: const Icon(Icons.help_outline_rounded),
                                label: const Text('Cómo jugar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo jugar'),
        content: const Text(
          'Inclina/gira el teléfono a izquierda o derecha para mover la nave.\n\n'
          'Pulsa el botón de disparo para destruir enemigos.\n\n'
          'Tienes 3 vidas. Los enemigos lanzan ráfagas, pero el juego limita '
          'los disparos simultáneos para mantener la partida jugable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
