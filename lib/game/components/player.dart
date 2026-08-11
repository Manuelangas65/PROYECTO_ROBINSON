import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';
import 'bullets.dart';
import 'enemy.dart';

class Player extends SpriteComponent
    with HasGameReference<GalagaGame>, CollisionCallbacks {
  Player({required super.position})
      : super(
          // El PNG tiene margen transparente; este tamaño hace que la nave
          // se perciba mucho más grande en pantalla horizontal.
          size: Vector2(118, 118),
          anchor: Anchor.center,
        );

  static const double movementSpeed = 500;
  double _shootCooldown = 0;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('player.png');
    add(
      RectangleHitbox.relative(
        Vector2(0.72, 0.72),
        parentSize: size,
        position: size * 0.14,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }

    // MOVER LA NAVE
    position.x += game.horizontalInput * movementSpeed * dt;

    // Evitar que salga de la pantalla
    final halfWidth = size.x / 2;

    position.x = position.x
        .clamp(
          halfWidth,
          game.size.x - halfWidth,
        )
        .toDouble();
  }

  void shoot() {
    if (_shootCooldown > 0 || game.isGameOver) return;

    _shootCooldown = 0.18;

    game.add(
      PlayerBullet(
        position: Vector2(
          position.x,
          position.y - (size.y / 2) - 12,
        ),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is EnemyBullet) {
      other.removeFromParent();
      game.playerHit();
    } else if (other is Enemy) {
      other.removeFromParent();
      game.playerHit();
    }
  }
}


//ES QUE HAS DE CUENTA QUE TODO LO QUE ESTAMOS HACIENDO 
//ESTA MAL PORQUE YA VES QUE LES ENSEÑÉ LA HOJA QUE 
//REALMENTE EL ES QUE LA USA, ENTONCES YA NO TIENE SENTIDO 
//NADA DE LO QUE ESTAMOS HACIENDO, ME ESTOY BASANDO EN 
//RESPONDERLES SUS PREGUNTAS A USTEDES Y A EL EN BASE A SUS 
//VIEJOS REQUERIMIENTOS DE AQUEL TONTO, AHORITA NADAMAS
//MULTIPLICA EL PRECIO PREDEFINIDO POR LA CANTIDAD DE PAQUETES
//Y LE RESTA SUS INVERSIONES DE GAS, FLETE, INDIRECTOS ETC
//
