import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../galaga_game.dart';
import 'bullets.dart';
import 'enemy.dart';

class Player extends SpriteComponent
    with HasGameReference<GalagaGame>, CollisionCallbacks {

  Player({required super.position})
      : super(
          size: Vector2(50, 50),
          anchor: Anchor.center,
        );

  static const double movementSpeed = 390;
  double _shootCooldown = 0;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('player.png');

    add(
      RectangleHitbox.relative(
        Vector2(0.42, 0.58),
        parentSize: size,

        // La centra dentro de la nave
        position: Vector2(
          size.x * 0.29,
          size.y * 0.21,
        ),

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
        position.y - (size.y / 2) - 5,
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
