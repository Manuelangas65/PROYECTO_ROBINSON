import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';

class PlayerBullet extends SpriteComponent
    with HasGameReference<GalagaGame> {
  PlayerBullet({required super.position})
      : super(
          size: Vector2(24, 50),
          anchor: Anchor.center,
        );

  static const double speed = 620;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('player_bullet.png');
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;

    if (position.y < -size.y) {
      removeFromParent();
    }
  }
}

class EnemyBullet extends SpriteComponent
    with HasGameReference<GalagaGame> {
  EnemyBullet({required super.position})
      : super(
          size: Vector2(22, 46),
          anchor: Anchor.center,
        );

  static const double speed = 340;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('enemy_bullet.png');
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}
