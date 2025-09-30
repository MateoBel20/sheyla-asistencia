import 'package:asistencia_sheyla/src/core/auth_service.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // alterna entre login y registro
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Verificar si ya hay un usuario logueado
      final currentUser = await AuthService.getCurrentUser();

      if (currentUser != null) {
        // Ya hay sesión activa
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ya has iniciado sesión como ${currentUser.email}"),
          ),
        );
      } else {
        if (_isLogin) {
          await AuthService.login(email, password);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inicio de sesión exitoso ✅")),
          );
        } else {
          await AuthService.register(email, password);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Registro exitoso ✅")));
        }
      }

      // Navegar a la pantalla principal
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/homes');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Iniciar Sesión" : "Registrar")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value != null && value.contains("@")
                      ? null
                      : "Email inválido",
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : "Mínimo 6 caracteres",
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_isLogin ? "Iniciar Sesión" : "Registrar"),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() => _isLogin = !_isLogin);
                  },
                  child: Text(
                    _isLogin
                        ? "¿No tienes cuenta? Regístrate"
                        : "¿Ya tienes cuenta? Inicia sesión",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
