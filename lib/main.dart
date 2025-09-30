import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/ui/pages/login_page.dart';
import 'src/ui/pages/attendance_list_page.dart';
import 'src/core/auth_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoggedIn() async {
    final user = await AuthService.getCurrentUser();
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: checkLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            // Si hay sesión activa, ir a la pantalla principal
            return const AttendanceListPage();
          } else {
            // No hay sesión, mostrar login
            return const LoginPage();
          }
        },
      ),
      routes: {
        '/homes': (context) => const AttendanceListPage(),
      },
    );
  }
}
