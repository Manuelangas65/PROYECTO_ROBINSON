import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'database_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  // ============================================================
  // ALGORITMO PARA CONTRASEÑAS
  // ============================================================

  final Argon2id _algorithm = Argon2id(
    // Aproximadamente 12 MB de memoria.
    memory: 12 * 1000,

    // Puede utilizar hasta 2 núcleos.
    parallelism: 2,

    iterations: 1,

    // Hash final de 32 bytes.
    hashLength: 32,
  );

  // Usuario que inició sesión.
  String? _currentUsername;

  String? get currentUsername => _currentUsername;

  bool get isLoggedIn => _currentUsername != null;

  // ============================================================
  // REGISTRAR USUARIO
  // ============================================================

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.toLowerCase().trim();

    // ----------------------------------------------------------
    // VALIDACIONES
    // ----------------------------------------------------------

    if (cleanUsername.length < 3) {
      throw Exception(
        'El usuario debe tener al menos 3 caracteres.',
      );
    }

    if (!RegExp(
      r'^[a-zA-Z0-9_]+$',
    ).hasMatch(cleanUsername)) {
      throw Exception(
        'El usuario solo puede contener letras, números y _.',
      );
    }

    if (password.length < 8) {
      throw Exception(
        'La contraseña debe tener al menos 8 caracteres.',
      );
    }

    final existing = await DatabaseService.instance.getUserByUsername(
      cleanUsername,
    );

    if (existing != null) {
      throw Exception(
        'Ese usuario ya existe.',
      );
    }

    // ----------------------------------------------------------
    // GENERAR SALT ALEATORIO
    // ----------------------------------------------------------

    final random = Random.secure();

    final salt = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );

    // ----------------------------------------------------------
    // HASH ARGON2ID
    // ----------------------------------------------------------

    final secretKey = await _algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final hashBytes = await secretKey.extractBytes();

    // Convertimos bytes a Base64 para almacenarlos.
    final hashBase64 = base64Encode(hashBytes);

    final saltBase64 = base64Encode(salt);

    // ----------------------------------------------------------
    // GUARDAR
    // ----------------------------------------------------------

    await DatabaseService.instance.insertUser(
      username: cleanUsername,
      passwordHash: hashBase64,
      salt: saltBase64,
    );
  }

  // ============================================================
  // INICIAR SESIÓN
  // ============================================================

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.toLowerCase().trim();

    final user = await DatabaseService.instance.getUserByUsername(
      cleanUsername,
    );

    if (user == null) {
      return false;
    }

    final storedHash = base64Decode(
      user['password_hash'] as String,
    );

    final salt = base64Decode(
      user['salt'] as String,
    );

    // Volvemos a aplicar Argon2id
    // usando exactamente el mismo salt.
    final candidateKey = await _algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final candidateHash = await candidateKey.extractBytes();

    final matches = _constantTimeEquals(
      candidateHash,
      storedHash,
    );

    if (matches) {
      _currentUsername = cleanUsername;
    }

    return matches;
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  void logout() {
    _currentUsername = null;
  }

  // ============================================================
  // COMPARACIÓN DE HASHES
  // ============================================================

  bool _constantTimeEquals(
    List<int> a,
    List<int> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }
}
