import 'dart:io';
import 'package:asistencia_sheyla/src/core/appwrite_service.dart';
import 'package:asistencia_sheyla/src/core/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/attendance.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  bool _loading = false;
  File? _photo;

  /// 📸 Elegir/tomar foto con la cámara
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  /// ✅ Registrar asistencia en Appwrite
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

      // 4️⃣ Subir foto si existe
      String? fotoId;
      if (_photo != null) {
        fotoId = await AppwriteService.uploadPhoto(_photo!.path);
      }

      // 5️⃣ Crear modelo de asistencia
      final attendance = Attendance(
        fecha: DateTime.now(),
        usuario: currentUser.$id, // userId correcto de Appwrite
        lat: position.latitude,
        lng: position.longitude,
        fotoId: fotoId,
      );

      // 6️⃣ Guardar en Appwrite
      await AppwriteService.createAttendance(attendance);

      // 7️⃣ Feedback al usuario
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_photo != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _photo!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar foto"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _takeAttendance,
                    icon: const Icon(Icons.check),
                    label: const Text("Registrar asistencia"),
                  ),
                ],
              ),
      ),
    );
  }
}
