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


class GalagaGame extends FlameGame
    with HasCollisionDetection {

  final void Function(GameResult result) onGameOver;


  GalagaGame({
    required this.onGameOver,
  });


  final Random _random = Random();


  final ValueNotifier<int> scoreNotifier =
      ValueNotifier<int>(0);

  final ValueNotifier<int> livesNotifier =
      ValueNotifier<int>(3);

  final ValueNotifier<bool> gyroAvailableNotifier =
      ValueNotifier<bool>(true);


  late Player player;


  StreamSubscription<GyroscopeEvent>?
      _gyroSubscription;


  double horizontalInput = 0;


  // ============================================================
  // GIROSCOPIO
  // ============================================================

  double _tiltAngle = 0.0;

  DateTime? _lastGyroEvent;


  static const double _maxTiltAngle = 0.20;

  static const double _gyroDeadZone = 0.012;

  static const double _gyroGain = 2.5;


  // ============================================================
  // DATOS DE PARTIDA
  // ============================================================

  int _score = 0;

  int _lives = 3;

  int _enemiesDestroyed = 0;


  double _spawnCountdown = 0.7;

  double _globalEnemyAttackCooldown = 0;

  double _damageCooldown = 0;


  bool _gameOver = false;

  late final DateTime _startedAt;


  bool get isGameOver => _gameOver;


  @override
  Color backgroundColor() =>
      const Color(0x00000000);


  // ============================================================
  // CARGA
  // ============================================================

  @override
  Future<void> onLoad() async {

    await super.onLoad();


    _startedAt = DateTime.now();


    await images.loadAll([
  'player.png',

  'enemy1.png',
  'enemy2.png',
  'enemy3.png',
  'enemy4.png',

  'player_bullet.png',
  'enemy_bullet.png',
]);


    player = Player(
      position: Vector2(
        size.x / 2,
        size.y - 78,
      ),
    );


    add(player);


    _listenToGyroscope();
  }


  // ============================================================
  // GIROSCOPIO
  // ============================================================

  void _listenToGyroscope() {

    _lastGyroEvent = null;


    _gyroSubscription =
        gyroscopeEvents.listen(

      (GyroscopeEvent event) {

        final now = DateTime.now();


        if (_lastGyroEvent == null) {

          _lastGyroEvent = now;

          return;
        }


        final dt = now
                .difference(_lastGyroEvent!)
                .inMicroseconds /
            1000000.0;


        _lastGyroEvent = now;


        if (dt <= 0 || dt > 0.1) {

          return;
        }


        double rotation = event.x;


        if (rotation.abs() < _gyroDeadZone) {

          rotation = 0;
        }


        _tiltAngle +=
            rotation * dt * _gyroGain;


        _tiltAngle = _tiltAngle
            .clamp(
              -_maxTiltAngle,
              _maxTiltAngle,
            )
            .toDouble();


        horizontalInput =
            (_tiltAngle / _maxTiltAngle)
                .clamp(-1.0, 1.0)
                .toDouble();


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


  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {

    super.update(dt);


    if (_gameOver) return;


    if (_globalEnemyAttackCooldown > 0) {

      _globalEnemyAttackCooldown -= dt;
    }


    if (_damageCooldown > 0) {

      _damageCooldown -= dt;
    }


    _spawnCountdown -= dt;


    if (_spawnCountdown <= 0) {

      _spawnEnemyIfPossible();


      final difficultyReduction =
          (_score / 6000)
              .clamp(0.0, 0.45)
              .toDouble();


      final base =
          1.15 - difficultyReduction;


      _spawnCountdown =
          base +
          _random.nextDouble() * 0.65;
    }
  }


  // ============================================================
  // CREAR ENEMIGO
  // ============================================================

  void _spawnEnemyIfPossible() {

    final enemiesOnScreen =
        children.whereType<Enemy>().length;


    // AQUÍ LIMITAMOS LA PANTALLA A 4 MARCIANOS
    if (
        enemiesOnScreen >= 4 ||
        size.x < 80
    ) {

      return;
    }


    const margin = 56.0;


    final usableWidth = max(
      1.0,
      size.x - margin * 2,
    );


    final x =
        margin +
        _random.nextDouble() *
            usableWidth;


    // ============================================================
    // TIPO RANDOM
    // ============================================================

    final type =
        EnemyType.values[
          _random.nextInt(
            EnemyType.values.length,
          )
        ];


    double fallSpeed =
        28 +
        _random.nextDouble() * 22;


    double horizontalSpeed =
        (_random.nextDouble() * 80) -
        40;


    // ============================================================
    // PERSONALIDAD DEL MOVIMIENTO
    // ============================================================

    switch (type) {

      case EnemyType.normal:

        // Movimiento normal
        break;


      case EnemyType.burst:

        // Algo más de movimiento lateral
        horizontalSpeed *= 1.15;

        break;


      case EnemyType.spread:

        // Más tranquilo verticalmente
        fallSpeed *= 0.90;

        break;


      case EnemyType.aggressive:

        // Más rápido
        fallSpeed *= 1.18;

        horizontalSpeed *= 1.55;

        break;
    }


    add(
      Enemy(
        position: Vector2(
          x,
          70,
        ),
        fallSpeed: fallSpeed,
        horizontalSpeed:
            horizontalSpeed,
        type: type,
      ),
    );
  }


  // ============================================================
  // DISPARO DEL JUGADOR
  // ============================================================

  void playerShoot() {

    if (_gameOver) return;

    player.shoot();
  }


  // ============================================================
  // DECIDIR ATAQUE DEL ENEMIGO
  // ============================================================

  void tryStartEnemyAttack(
    Enemy enemy,
  ) {

    if (
        _gameOver ||
        _globalEnemyAttackCooldown > 0
    ) {

      return;
    }


    final enemyBullets =
        children
            .whereType<EnemyBullet>()
            .length;


    // Evitar llenar completamente la pantalla
    if (enemyBullets >= 12) {

      return;
    }


    // 70% de probabilidad de atacar cuando
    // su temporizador llega a cero.
    if (_random.nextDouble() > 0.70) {

      return;
    }


    // ============================================================
    // ATAQUE SEGÚN TIPO
    // ============================================================

    switch (enemy.type) {

      // ----------------------------------------------------------
      // 1. MARCIANO NORMAL
      // Una bala recta
      // ----------------------------------------------------------

      case EnemyType.normal:

        spawnEnemyBulletFrom(
          enemy,
          verticalSpeed: 340,
        );


        _globalEnemyAttackCooldown =
            0.30 +
            _random.nextDouble() * 0.25;

        break;


      // ----------------------------------------------------------
      // 2. MARCIANO DE RÁFAGA
      //
      // pum pum pum
      // ----------------------------------------------------------

      case EnemyType.burst:

        enemy.beginBurst(
          3,
          gap: 0.15,
          bulletVerticalSpeed: 355,
        );


        _globalEnemyAttackCooldown =
            0.45;

        break;


      // ----------------------------------------------------------
      // 3. MARCIANO ABANICO
      //
      //       👾
      //     ↙ ↓ ↘
      //
      // ----------------------------------------------------------

      case EnemyType.spread:

        spawnEnemyBulletFrom(
          enemy,
          horizontalSpeed: -150,
          verticalSpeed: 320,
          xOffset: -18,
        );


        spawnEnemyBulletFrom(
          enemy,
          horizontalSpeed: 0,
          verticalSpeed: 340,
        );


        spawnEnemyBulletFrom(
          enemy,
          horizontalSpeed: 150,
          verticalSpeed: 320,
          xOffset: 18,
        );


        _globalEnemyAttackCooldown =
            0.55;

        break;


      // ----------------------------------------------------------
      // 4. MARCIANO AGRESIVO
      //
      // pum pum pum pum pum
      //
      // ----------------------------------------------------------

      case EnemyType.aggressive:

        enemy.beginBurst(
          5,
          gap: 0.09,
          bulletVerticalSpeed: 430,
        );


        _globalEnemyAttackCooldown =
            0.65;

        break;
    }
  }


  // ============================================================
  // CREAR BALA ENEMIGA
  // ============================================================

  bool spawnEnemyBulletFrom(
    Enemy enemy, {
    double horizontalSpeed = 0,
    double verticalSpeed = 340,
    double xOffset = 0,
  }) {

    if (_gameOver) return false;


    final enemyBullets =
        children
            .whereType<EnemyBullet>()
            .length;


    // Un poquito más alto porque ahora
    // existen ataques de 3 y 5 balas.
    if (enemyBullets >= 14) {

      return false;
    }


    add(
      EnemyBullet(
        position: Vector2(
          enemy.position.x +
              xOffset,

          enemy.position.y +
              (enemy.size.y / 2) +
              12,
        ),

        horizontalSpeed:
            horizontalSpeed,

        verticalSpeed:
            verticalSpeed,
      ),
    );


    return true;
  }


  // ============================================================
  // ENEMIGO DESTRUIDO
  // ============================================================

  void enemyDestroyed() {

    if (_gameOver) return;


    _enemiesDestroyed++;


    _score += 100;


    scoreNotifier.value =
        _score;
  }


  // ============================================================
  // ENEMIGO ESCAPA
  // ============================================================

  void enemyEscaped() {

    // No quita vidas.
    // El peligro sigue siendo:
    //
    // - disparos
    // - colisiones
  }


  // ============================================================
  // JUGADOR RECIBE DAÑO
  // ============================================================

  void playerHit() {

    if (
        _gameOver ||
        _damageCooldown > 0
    ) {

      return;
    }


    _damageCooldown = 0.9;


    _lives--;


    livesNotifier.value =
        _lives;


    if (_lives <= 0) {

      _finishGame();
    }
  }


  // ============================================================
  // FIN DE PARTIDA
  // ============================================================

  void _finishGame() {

    if (_gameOver) return;


    _gameOver = true;


    pauseEngine();


    final duration =
        DateTime.now()
            .difference(_startedAt)
            .inSeconds;


    final hour =
        DateTime.now().hour;


    final contextMode =
        (hour >= 7 && hour < 19)
            ? 'day'
            : 'night';


    onGameOver(
      GameResult(
        score: _score,
        enemiesDestroyed:
            _enemiesDestroyed,
        durationSeconds:
            duration,
        contextMode:
            contextMode,
      ),
    );
  }


  // ============================================================
  // LIMPIEZA
  // ============================================================

  @override
  void onRemove() {

    _gyroSubscription?.cancel();


    scoreNotifier.dispose();

    livesNotifier.dispose();

    gyroAvailableNotifier.dispose();


    super.onRemove();
  }
}