import 'package:asistencia_sheyla/src/core/appwrite_service.dart';
import 'package:asistencia_sheyla/src/core/auth_service.dart';
import 'package:asistencia_sheyla/src/ui/pages/take_attendance_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:appwrite/models.dart' as models;

class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  List<models.Document> _attendances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() => _loading = true);
    final currentUser = await AuthService.getCurrentUser();

    if (currentUser != null) {
      try {
        final docs = await AppwriteService.listUserAttendances(currentUser.$id);

        docs.sort((a, b) {
          final fechaA =
              DateTime.tryParse(a.data['fecha'] ?? '') ?? DateTime(2000);
          final fechaB =
              DateTime.tryParse(b.data['fecha'] ?? '') ?? DateTime(2000);
          return fechaB.compareTo(fechaA); // descendente
        });

        setState(() {
          _attendances = docs; // puede ser vacío
        });
      } catch (e) {
        // En caso de error de conexión
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar asistencias: $e")),
        );
        setState(() {
          _attendances = [];
        });
      }
    } else {
      // Usuario no logueado (esto no debería pasar)
      setState(() {
        _attendances = [];
      });
    }

    // Siempre desactivar loading
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro que quieres cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _goToTakeAttendance() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TakeAttendancePage()),
    );

    // Si el usuario tomó asistencia, recargar la lista
    if (result == true) {
      _loadAttendances();
    }
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attendances.isEmpty
          ? const Center(
              child: Text(
                "No tienes asistencias registradas",
                style: TextStyle(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAttendances,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _attendances.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _attendances[index].data;

                  final lat = item['lat'];
                  final lng = item['lng'];
                  final ubicacion = (lat != null && lng != null)
                      ? '$lat, $lng'
                      : 'No registrada';

                  return ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Fecha: ${item['fecha']}"),
                    subtitle: Text(
                      "Ubicación: $ubicacion"//\nUsuario: ${item['usuario']}",
                    ),
                  );
                },
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _goToTakeAttendance,
        child: const Icon(Icons.add),
      ),
    );
  }
}
