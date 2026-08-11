import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/game_record.dart';
import 'components/bullets.dart';
import 'components/enemy.dart';
import 'components/player.dart';

class GalagaGame extends FlameGame with HasCollisionDetection {
  final void Function(GameResult result) onGameOver;

  GalagaGame({
    required this.onGameOver,
  });

  final Random _random = Random();

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(3);
  final ValueNotifier<bool> gyroAvailableNotifier = ValueNotifier<bool>(true);

  late Player player;

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  double horizontalInput = 0;

// Inclinación virtual acumulada
  double _tiltAngle = 0.0;

// Momento del último evento del giroscopio
  DateTime? _lastGyroEvent;

  static const double _maxTiltAngle = 0.20;
  static const double _gyroDeadZone = 0.012;

// Qué tan rápido responde la inclinación
  static const double _gyroGain = 2.5;

  int _score = 0;
  int _lives = 3;
  int _enemiesDestroyed = 0;

  double _spawnCountdown = 0.7;
  double _globalEnemyBurstCooldown = 0;
  double _damageCooldown = 0;

  bool _gameOver = false;
  late final DateTime _startedAt;

  bool get isGameOver => _gameOver;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _startedAt = DateTime.now();

    await images.loadAll([
      'player.png',
      'enemy.png',
      'player_bullet.png',
      'enemy_bullet.png',
    ]);

    player = Player(
      position: Vector2(size.x / 2, size.y - 78),
    );
    add(player);

    _listenToGyroscope();
  }

  void _listenToGyroscope() {
    _lastGyroEvent = null;

    _gyroSubscription = gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        final now = DateTime.now();

        // El primer evento solamente sirve como referencia de tiempo
        if (_lastGyroEvent == null) {
          _lastGyroEvent = now;
          return;
        }

        // Tiempo transcurrido entre lecturas
        final dt = now.difference(_lastGyroEvent!).inMicroseconds / 1000000.0;

        _lastGyroEvent = now;

        // Evita saltos extraños
        if (dt <= 0 || dt > 0.1) {
          return;
        }

        // Eje que ya comprobamos que corresponde
        // a izquierda/derecha en horizontal
        double rotation = event.x;

        // Ignorar pequeños movimientos involuntarios
        if (rotation.abs() < _gyroDeadZone) {
          rotation = 0;
        }

        // ACUMULAMOS la rotación.
        // Aquí está la diferencia importante.
        _tiltAngle += rotation * dt * _gyroGain;

        // Limitar la inclinación virtual
        _tiltAngle = _tiltAngle.clamp(-_maxTiltAngle, _maxTiltAngle).toDouble();

        // Convertimos el ángulo a un valor entre -1 y 1
        horizontalInput =
            (_tiltAngle / _maxTiltAngle).clamp(-1.0, 1.0).toDouble();

        // Pequeña zona muerta en el centro
        if (horizontalInput.abs() < 0.04) {
          horizontalInput = 0;
        }
      },
      onError: (_) {
        gyroAvailableNotifier.value = false;
        horizontalInput = 0;
      },
      cancelOnError: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver) return;

    if (_globalEnemyBurstCooldown > 0) {
      _globalEnemyBurstCooldown -= dt;
    }

    if (_damageCooldown > 0) {
      _damageCooldown -= dt;
    }

    _spawnCountdown -= dt;
    if (_spawnCountdown <= 0) {
      _spawnEnemyIfPossible();

      final difficultyReduction = (_score / 6000).clamp(0.0, 0.55).toDouble();
      final base = 1.25 - difficultyReduction;
      _spawnCountdown = base + _random.nextDouble() * 0.75;
    }
  }

  void _spawnEnemyIfPossible() {
    final enemiesOnScreen = children.whereType<Enemy>().length;
    if (enemiesOnScreen >= 7 || size.x < 80) return;

    const margin = 56.0;
    final usableWidth = max(1.0, size.x - margin * 2);
    final x = margin + _random.nextDouble() * usableWidth;

    final fallSpeed = 28 + _random.nextDouble() * 22;
    final horizontalSpeed = (_random.nextDouble() * 80) - 40;

    add(
      Enemy(
        position: Vector2(x, 70),
        fallSpeed: fallSpeed,
        horizontalSpeed: horizontalSpeed,
      ),
    );
  }

  void playerShoot() {
    if (_gameOver) return;
    player.shoot();
  }

  void tryStartEnemyBurst(Enemy enemy) {
    if (_gameOver || _globalEnemyBurstCooldown > 0) return;

    final enemyBullets = children.whereType<EnemyBullet>().length;
    if (enemyBullets >= 7) return;

    // No todos los enemigos disparan cuando su temporizador llega a cero.
    // Además existe un cooldown global para impedir disparos simultáneos masivos.
    if (_random.nextDouble() > 0.62) return;

    _globalEnemyBurstCooldown = 0.38 + _random.nextDouble() * 0.45;
    enemy.beginBurst(2 + _random.nextInt(2));
  }

  bool spawnEnemyBulletFrom(Enemy enemy) {
    if (_gameOver) return false;

    final enemyBullets = children.whereType<EnemyBullet>().length;
    if (enemyBullets >= 8) return false;

    add(
      EnemyBullet(
        position: Vector2(
          enemy.position.x,
          enemy.position.y + (enemy.size.y / 2) + 12,
        ),
      ),
    );

    return true;
  }

  void enemyDestroyed() {
    if (_gameOver) return;

    _enemiesDestroyed++;
    _score += 100;
    scoreNotifier.value = _score;
  }

  void enemyEscaped() {
    // En esta versión no quita vida: evita que una mala racha de spawns vuelva
    // injusta la partida. El peligro real son los disparos y choques.
  }

  void playerHit() {
    if (_gameOver || _damageCooldown > 0) return;

    _damageCooldown = 0.9;
    _lives--;
    livesNotifier.value = _lives;

    if (_lives <= 0) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_gameOver) return;

    _gameOver = true;
    pauseEngine();

    final duration = DateTime.now().difference(_startedAt).inSeconds;
    final hour = DateTime.now().hour;
    final contextMode = (hour >= 7 && hour < 19) ? 'day' : 'night';

    onGameOver(
      GameResult(
        score: _score,
        enemiesDestroyed: _enemiesDestroyed,
        durationSeconds: duration,
        contextMode: contextMode,
      ),
    );
  }

  @override
  void onRemove() {
    _gyroSubscription?.cancel();
    scoreNotifier.dispose();
    livesNotifier.dispose();
    gyroAvailableNotifier.dispose();
    super.onRemove();
  }
}
