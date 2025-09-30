import 'package:asistencia_sheyla/src/core/auth_service.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  List<Map<String, dynamic>> _attendances = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
    // 👉 más adelante reemplazaremos _loadDummyData por la consulta a Appwrite
  }

  void _loadDummyData() {
    setState(() {
      _attendances = [
        {"fecha": "2025-09-30", "usuario": "mateo@example.com", "ubicacion": "Lat:-0.1807, Lng:-78.4678"},
        {"fecha": "2025-09-29", "usuario": "juan@example.com", "ubicacion": "Lat:-2.1894, Lng:-79.8891"},
      ];
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _goToTakeAttendance() {
    // TODO: implementar la pantalla "Tomar asistencia"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aquí irá la pantalla de tomar asistencia 📌")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis asistencias"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: _attendances.isEmpty
          ? const Center(child: Text("No tienes asistencias registradas"))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _attendances.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _attendances[index];
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Fecha: ${item['fecha']}"),
                  subtitle: Text("Usuario: ${item['usuario']}\nUbicación: ${item['ubicacion']}"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTakeAttendance,
        child: const Icon(Icons.add),
      ),
    );
  }
}
