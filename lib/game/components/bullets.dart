import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';


// ============================================================
// BALA DEL JUGADOR
// ============================================================

class PlayerBullet extends SpriteComponent
    with HasGameReference<GalagaGame> {

  PlayerBullet({
    required super.position,
  }) : super(
          size: Vector2(25, 35),
          anchor: Anchor.center,
        );


  static const double speed = 620;


  @override
  Future<void> onLoad() async {

    sprite = await game.loadSprite(
      'player_bullet.png',
    );


    add(
      RectangleHitbox.relative(
        Vector2(0.50, 0.72),
        parentSize: size,
        position: Vector2(
          size.x * 0.25,
          size.y * 0.14,
        ),
        collisionType: CollisionType.passive,
      ),
    );
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


// ============================================================
// BALA DEL ENEMIGO
// ============================================================

class EnemyBullet extends SpriteComponent
    with HasGameReference<GalagaGame> {

  final double horizontalSpeed;

  final double verticalSpeed;


  EnemyBullet({
    required super.position,
    this.horizontalSpeed = 0,
    this.verticalSpeed = 340,
  }) : super(
          size: Vector2(22, 46),
          anchor: Anchor.center,
        );


  @override
  Future<void> onLoad() async {

    sprite = await game.loadSprite(
      'enemy_bullet.png',
    );


    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
      ),
    );
  }


  @override
  void update(double dt) {

    super.update(dt);


    // Movimiento vertical
    position.y += verticalSpeed * dt;


    // Movimiento horizontal
    position.x += horizontalSpeed * dt;


    // Eliminar si sale de pantalla
    if (
        position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x
    ) {

      removeFromParent();
    }
  }
}