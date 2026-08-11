import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/galaga_game.dart';
import '../models/game_record.dart';
import '../services/audio_service.dart';
import '../services/database_service.dart';
import '../widgets/context_background.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GalagaGame _game;
  bool _paused = false;
  bool _showingGameOver = false;
  bool _restarting = false;

  @override
  void initState() {
    super.initState();

    _game = GalagaGame(
      onGameOver: (result) {
        _handleGameOver(result);
      },
    );

    unawaited(AudioService.instance.playMusic());
  }

  @override
  void dispose() {
    // Al reintentar se crea otra GameScreen usando el mismo AudioService.
    // Si la pantalla vieja detuviera el reproductor aquí, apagaría la música
    // que la nueva pantalla acaba de iniciar.
    if (!_restarting) {
      unawaited(AudioService.instance.stopMusic());
    }
    super.dispose();
  }

  Future<void> _handleGameOver(GameResult result) async {
    if (_showingGameOver) return;
    _showingGameOver = true;

    await DatabaseService.instance.insertGame(
      GameRecord(
        score: result.score,
        enemiesDestroyed: result.enemiesDestroyed,
        durationSeconds: result.durationSeconds,
        playedAt: DateTime.now(),
        contextMode: result.contextMode,
      ),
    );

    await AudioService.instance.stopMusic();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('GAME OVER'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntuación: ${result.score}'),
                Text('Enemigos destruidos: ${result.enemiesDestroyed}'),
                Text('Duración: ${result.durationSeconds} s'),
                Text(
                  'Contexto: ${result.contextMode == 'day' ? 'día' : 'noche'}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Salir'),
            ),
            FilledButton(
              onPressed: () {
                _restarting = true;
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(),
                  ),
                );
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _togglePause() async {
    if (_game.isGameOver) return;

    setState(() {
      _paused = !_paused;
    });

    if (_paused) {
      _game.pauseEngine();
      await AudioService.instance.pauseMusic();
    } else {
      _game.resumeEngine();
      await AudioService.instance.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContextBackground(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameWidget(game: _game),
              Positioned(
                top: 10,
                left: 14,
                child: _Hud(game: _game),
              ),
              Positioned(
                top: 8,
                right: 10,
                child: IconButton.filledTonal(
                  onPressed: _togglePause,
                  icon: Icon(
                    _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 22,
                child: GestureDetector(
                  onTap: _paused ? null : _game.playerShoot,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withValues(alpha: 0.88),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 14,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_paused)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                      child: Text(
                        'PAUSA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  final GalagaGame game;

  const _Hud({required this.game});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (_, score, __) => Text(
                'Puntos: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 3),
            ValueListenableBuilder<int>(
              valueListenable: game.livesNotifier,
              builder: (_, lives, __) => Text(
                'Vidas: ${List.filled(lives, '♥').join()}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 3),
            ValueListenableBuilder<bool>(
              valueListenable: game.gyroAvailableNotifier,
              builder: (_, available, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.screen_rotation_alt_rounded,
                    size: 16,
                    color: available ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    available
                        ? 'Giroscopio activo'
                        : 'Giroscopio no disponible',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
