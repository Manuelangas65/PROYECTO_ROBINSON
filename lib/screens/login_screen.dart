import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();

    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage(
        'Ingresa usuario y contraseña.',
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final success = await AuthService.instance.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (!success) {
        _showMessage(
          'Usuario o contraseña incorrectos.',
        );

        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'No se pudo iniciar sesión.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // MISMO FONDO ESPACIAL
          Image.asset(
            'assets/images/menu_space.jpg',
            fit: BoxFit.cover,
          ),

          Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 430,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.68,
                    ),
                    borderRadius: BorderRadius.circular(
                      24,
                    ),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.rocket_launch_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'GALAGA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      TextField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(
                            Icons.person_rounded,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        onSubmitted: (_) {
                          if (!_loading) {
                            _login();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_rounded,
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'INICIAR SESIÓN',
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Crear una cuenta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
