import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';
import 'bullets.dart';

// ============================================================
// TIPOS DE MARCIANOS
// ============================================================

enum EnemyType {
  normal,
  burst,
  spread,
  aggressive,
}

class Enemy extends SpriteComponent
    with HasGameReference<GalagaGame>, CollisionCallbacks {
  final double fallSpeed;

  double horizontalSpeed;

  final EnemyType type;

  final Random _random = Random();

  // Tiempo para decidir el siguiente ataque
  double _attackTimer = 1.5;

  // Sistema de ráfagas
  int _burstRemaining = 0;

  double _burstGapTimer = 0;

  double _burstGap = 0.14;

  double _burstVerticalSpeed = 340;

  Enemy({
    required super.position,
    required this.fallSpeed,
    required this.horizontalSpeed,
    required this.type,
  }) : super(
          size: Vector2(50, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Por ahora todos usan el mismo sprite.
    // Más adelante podemos poner enemy1.png, enemy2.png, etc.
    String spriteName;

    switch (type) {
      case EnemyType.normal:
        spriteName = 'enemy1.png';
        break;

      case EnemyType.burst:
        spriteName = 'enemy2.png';
        break;

      case EnemyType.spread:
        spriteName = 'enemy3.png';
        break;

      case EnemyType.aggressive:
        spriteName = 'enemy4.png';
        break;
    }

    sprite = await game.loadSprite(spriteName);

    add(
      RectangleHitbox.relative(
        Vector2(0.72, 0.64),
        parentSize: size,
        position: Vector2(
          size.x * 0.14,
          size.y * 0.18,
        ),
        collisionType: CollisionType.active,
      ),
    );

    _attackTimer = _getNextAttackDelay();
  }

  // ============================================================
  // TIEMPO DE ATAQUE SEGÚN EL MARCIANO
  // ============================================================

  double _getNextAttackDelay() {
    switch (type) {
      // Dispara más tranquilo
      case EnemyType.normal:
        return 1.8 + _random.nextDouble() * 2.4;

      // Hace ráfagas
      case EnemyType.burst:
        return 1.5 + _random.nextDouble() * 2.0;

      // Ataque en abanico
      case EnemyType.spread:
        return 1.8 + _random.nextDouble() * 2.0;

      // Ataca más seguido
      case EnemyType.aggressive:
        return 1.0 + _random.nextDouble() * 1.5;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ============================================================
    // MOVIMIENTO
    // ============================================================

    position.y += fallSpeed * dt;

    position.x += horizontalSpeed * dt;

    final halfWidth = size.x / 2;

    // Rebote contra los bordes
    if (position.x <= halfWidth) {
      position.x = halfWidth;

      horizontalSpeed = horizontalSpeed.abs();
    } else if (position.x >= game.size.x - halfWidth) {
      position.x = game.size.x - halfWidth;

      horizontalSpeed = -horizontalSpeed.abs();
    }

    // ============================================================
    // RÁFAGA EN PROCESO
    // ============================================================

    if (_burstRemaining > 0) {
      _burstGapTimer -= dt;

      if (_burstGapTimer <= 0) {
        final fired = game.spawnEnemyBulletFrom(
          this,
          verticalSpeed: _burstVerticalSpeed,
        );

        if (fired) {
          _burstRemaining--;

          _burstGapTimer = _burstGap;
        } else {
          // Si hay demasiadas balas esperamos poquito
          _burstGapTimer = 0.08;
        }
      }
    } else {
      // ============================================================
      // NUEVA DECISIÓN DE ATAQUE
      // ============================================================

      _attackTimer -= dt;

      if (_attackTimer <= 0) {
        game.tryStartEnemyAttack(this);

        _attackTimer = _getNextAttackDelay();
      }
    }

    // ============================================================
    // ENEMIGO SALE DE PANTALLA
    // ============================================================

    if (position.y > game.size.y + size.y) {
      removeFromParent();

      game.enemyEscaped();
    }
  }

  // ============================================================
  // INICIAR RÁFAGA
  // ============================================================

  void beginBurst(
    int bullets, {
    double gap = 0.14,
    double bulletVerticalSpeed = 340,
  }) {
    if (_burstRemaining > 0) return;

    _burstRemaining = bullets;

    _burstGap = gap;

    _burstVerticalSpeed = bulletVerticalSpeed;

    _burstGapTimer = 0;
  }

  // ============================================================
  // COLISIÓN CON BALA DEL JUGADOR
  // ============================================================

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (other is PlayerBullet) {
      other.removeFromParent();

      removeFromParent();

      game.enemyDestroyed();
    }
  }
}
