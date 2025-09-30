import 'package:asistencia_sheyla/src/core/appwrite_service.dart';
import 'package:asistencia_sheyla/src/core/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/attendance.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  bool _loading = false;

  Future<void> _takeAttendance() async {
    setState(() => _loading = true);

    try {
      // 1️⃣ Usuario logueado
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) throw "Usuario no logueado";

      // 2️⃣ Pedir permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw "Permiso de ubicación denegado";
      }

      // 3️⃣ Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4️⃣ Crear modelo de asistencia
      final attendance = Attendance(
        fecha: DateTime.now(),
        usuario: currentUser.$id, // userId correcto de Appwrite
        lat: position.latitude,
        lng: position.longitude,
      );

      // 5️⃣ Guardar en Appwrite
      await AppwriteService.createAttendance(attendance);

      // 6️⃣ Feedback al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Asistencia registrada ✅")),
        );
        Navigator.pop(context, true); // regresar y refrescar lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tomar asistencia")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _takeAttendance,
                icon: const Icon(Icons.check),
                label: const Text("Registrar asistencia"),
              ),
      ),
    );
  }
}