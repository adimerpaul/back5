import 'package:flutter/material.dart';
import '../services/DatabaseHelper.dart';
import '../services/SnackbarHelper.dart';
import 'MapaPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _obscureText = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    verifyUser();
    _usernameController.text = 'admin';
    _passwordController.text = 'admin';
    super.initState();
  }
  Future<void> verifyUser() async {
    setState(() {
      _isLoading = true;
    });
    final user = await DatabaseHelper().getUser();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapaPage())
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showError(context, 'Por favor, complete todos los campos');
      return;
    }

    setState(() {
      _isLoading = true; // Activar el estado de carga
    });

    try {
      await DatabaseHelper().insertUser({
        'user_id': '1',
        'name': _usernameController.text,
      });
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapaPage())
      );
    } catch (e) {
      print('Error al insertar el usuario: $e');
    } finally {
      setState(() {
        _isLoading = false; // Desactivar el estado de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80.0),
            Image.asset(
              'assets/logo.png',
              height: 100.0, // Puedes ajustar la altura según necesites
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.0), // Botón ancho
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Lógica de recuperación de contraseña
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
