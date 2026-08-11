# GALAXY GYRO - Proyecto final Flutter

Juego tipo Galaga preparado para cubrir:

- Persistencia local con SQLite.
- Sensibilidad al contexto según hora del dispositivo.
- Uso de giroscopio para mover la nave.
- Disparos del jugador.
- Enemigos aleatorios.
- Ráfagas enemigas limitadas para que no disparen todos al mismo tiempo.
- Música local en loop.
- Historial de partidas y puntuaciones.

## 1. Crear el proyecto base

En PowerShell o terminal:

```bash
flutter create galaga_final
cd galaga_final
```

Luego reemplaza dentro del proyecto las carpetas/archivos de este paquete:

- `lib/`
- `assets/`
- `pubspec.yaml`

Después:

```bash
flutter pub get
flutter run
```

> IMPORTANTE: prueba el giroscopio en un teléfono físico. En emulador normalmente no tendrás el comportamiento real del sensor.

## 2. Tus imágenes

Reemplaza estos archivos SIN cambiarles el nombre:

```text
assets/images/player.png
assets/images/enemy.png
assets/images/player_bullet.png
assets/images/enemy_bullet.png
```

Se recomienda PNG con fondo transparente.

Si tus nombres son otros, puedes cambiarlos en:

- `lib/game/galaga_game.dart`
- `lib/game/components/player.dart`
- `lib/game/components/enemy.dart`
- `lib/game/components/bullets.dart`

## 3. Tu canción

Ahora existe un audio silencioso de prueba:

```text
assets/audio/music.wav
```

Si quieres usar MP3:

1. Copia tu canción a:

```text
assets/audio/music.mp3
```

2. Abre:

```text
lib/services/audio_service.dart
```

3. Cambia:

```dart
static const String musicAsset = 'audio/music.wav';
```

por:

```dart
static const String musicAsset = 'audio/music.mp3';
```

## 4. Sensibilidad del giroscopio

En:

```text
lib/game/galaga_game.dart
```

busca:

```dart
double gyroSensitivity = 3.4;
```

- Si se mueve muy lento: súbelo a `4.0` o `5.0`.
- Si se mueve demasiado: bájalo a `2.0` o `2.5`.

## 5. SQLite

Base de datos local:

```text
galaxy_gyro.db
```

Tabla:

```sql
games(
  id,
  score,
  enemies_destroyed,
  duration_seconds,
  played_at,
  context_mode
)
```

Cada Game Over crea un registro nuevo.

## 6. Sensibilidad al contexto

La app consulta `DateTime.now().hour`.

- 07:00 a 18:59 -> modo día, fondo claro y sol.
- 19:00 a 06:59 -> modo noche, fondo oscuro, estrellas y luna.

La partida también guarda si ocurrió de día o de noche.

## 7. Enemigos y ráfagas

Cada enemigo tiene su propio temporizador.

Además, `GalagaGame` controla:

- cooldown global de ráfagas;
- probabilidad de disparo;
- máximo de balas enemigas en pantalla;
- ráfagas de 2 o 3 balas.

Esto evita que todos los enemigos disparen exactamente al mismo tiempo.

## 8. Seguridad para explicar al profesor

- La BD es local, no se expone por red.
- No hay contraseñas ni llaves API hardcodeadas.
- Los datos se insertan mediante la API parametrizada de `sqflite`.
- SQLite usa restricciones `CHECK` para impedir valores negativos o contextos inválidos.
- No se solicitan permisos innecesarios de archivos o red.
- Los datos permanecen dentro del almacenamiento privado de la app.

## 9. Para la exposición

Demuestra en este orden:

1. Abre la app y enseña que aparece sol o luna según la hora.
2. Inicia partida.
3. Mueve la nave físicamente con el teléfono.
4. Dispara y destruye enemigos.
5. Deja que un enemigo dispare una ráfaga.
6. Pierde las 3 vidas para provocar Game Over.
7. Abre Puntuaciones y enseña que SQLite guardó la partida.
8. Explica el código de contexto, sensor y base de datos.
9. Explica las medidas de seguridad.

## 10. APK y QR

Cuando ya funcione:

```bash
flutter build apk --release
```

El APK normalmente queda en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Sube ese APK a un servicio accesible para tu profesor y genera un QR con el enlace de descarga.
