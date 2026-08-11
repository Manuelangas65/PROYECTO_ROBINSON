import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';
import 'bullets.dart';

class Enemy extends SpriteComponent
    with HasGameReference<GalagaGame>, CollisionCallbacks {
  final double fallSpeed;
  double horizontalSpeed;
  final Random _random = Random();

  double _shotDecisionTimer = 1.5;
  int _burstRemaining = 0;
  double _burstGapTimer = 0;

  Enemy({
    required super.position,
    required this.fallSpeed,
    required this.horizontalSpeed,
  }) : super(
          size: Vector2(100, 100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('enemy.png');
    add(
      RectangleHitbox.relative(
        Vector2(0.72, 0.64),
        parentSize: size,
        position: Vector2(size.x * 0.14, size.y * 0.18),
        collisionType: CollisionType.active,
      ),
    );
    _shotDecisionTimer = 1.0 + _random.nextDouble() * 2.8;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += fallSpeed * dt;
    position.x += horizontalSpeed * dt;

    final halfWidth = size.x / 2;
    if (position.x <= halfWidth) {
      position.x = halfWidth;
      horizontalSpeed = horizontalSpeed.abs();
    } else if (position.x >= game.size.x - halfWidth) {
      position.x = game.size.x - halfWidth;
      horizontalSpeed = -horizontalSpeed.abs();
    }

    if (_burstRemaining > 0) {
      _burstGapTimer -= dt;
      if (_burstGapTimer <= 0) {
        final fired = game.spawnEnemyBulletFrom(this);
        if (fired) {
          _burstRemaining--;
          _burstGapTimer = 0.14;
        } else {
          _burstGapTimer = 0.08;
        }
      }
    } else {
      _shotDecisionTimer -= dt;
      if (_shotDecisionTimer <= 0) {
        _shotDecisionTimer = 1.5 + _random.nextDouble() * 3.0;
        game.tryStartEnemyBurst(this);
      }
    }

    if (position.y > game.size.y + size.y) {
      removeFromParent();
      game.enemyEscaped();
    }
  }

  void beginBurst(int bullets) {
    if (_burstRemaining > 0) return;
    _burstRemaining = bullets;
    _burstGapTimer = 0;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerBullet) {
      other.removeFromParent();
      removeFromParent();
      game.enemyDestroyed();
    }
  }
}
