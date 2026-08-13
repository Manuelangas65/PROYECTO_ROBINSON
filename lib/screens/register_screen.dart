import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();

    final password = _passwordController.text;

    final confirm = _confirmController.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage(
        'Completa todos los campos.',
      );

      return;
    }

    if (password != confirm) {
      _showMessage(
        'Las contraseñas no coinciden.',
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.register(
        username: username,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cuenta creada correctamente.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      var message = e.toString();

      message = message.replaceFirst(
        'Exception: ',
        '',
      );

      _showMessage(message);
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
          Image.asset(
            'assets/images/menu_space.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.50),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.70,
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
                      const Text(
                        'CREAR CUENTA',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(
                            Icons.person_rounded,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
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
                        height: 14,
                      ),
                      TextField(
                        controller: _confirmController,
                        obscureText: _hidePassword,
                        onSubmitted: (_) {
                          if (!_loading) {
                            _register();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mínimo 8 caracteres',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'REGISTRAR',
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.of(
                                  context,
                                ).pop();
                              },
                        child: const Text(
                          'Volver',
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
