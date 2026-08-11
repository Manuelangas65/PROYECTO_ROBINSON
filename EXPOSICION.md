# Guion técnico corto para exposición

## Descripción

Galaxy Gyro es un videojuego móvil tipo Galaga desarrollado en Flutter. El jugador controla una nave mediante el giroscopio del teléfono, dispara a enemigos que aparecen aleatoriamente y debe esquivar ráfagas enemigas.

## Persistencia

Se utiliza SQLite mediante `sqflite`. Al terminar cada partida se guardan puntuación, enemigos destruidos, duración, fecha/hora y el contexto día/noche. La pantalla Puntuaciones recupera esos registros y los ordena por puntaje.

## Sensibilidad al contexto

La aplicación consulta la hora local del dispositivo con `DateTime.now()`. Entre 07:00 y 18:59 utiliza contexto diurno y muestra un sol; fuera de ese horario utiliza contexto nocturno y muestra luna y estrellas. El contexto también se almacena junto con la partida.

## Sensor

Se utiliza `sensors_plus` para escuchar eventos del giroscopio. El eje Y controla el movimiento horizontal de la nave. La lectura se multiplica por un factor de sensibilidad y se limita para evitar movimientos bruscos.

## Lógica de enemigos

Los enemigos se generan en posiciones X aleatorias en la parte superior. Cada enemigo posee su propio temporizador de disparo, pero además existe un cooldown global, una probabilidad de disparo y un máximo de balas enemigas. Esto evita que todos disparen simultáneamente y mantiene la dificultad jugable.

## Seguridad

No se emplea una API externa ni se exponen datos por Internet. SQLite permanece local dentro del almacenamiento privado de la aplicación. No existen contraseñas o tokens hardcodeados. Las escrituras se realizan con la API de `sqflite` y la tabla incluye restricciones de integridad para valores inválidos.
