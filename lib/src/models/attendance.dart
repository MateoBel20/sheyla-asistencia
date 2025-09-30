class Attendance {
  final String? id; // $id de Appwrite
  final DateTime fecha; // guarda fecha (puede ser fecha completa o solo YYYY-MM-DD)
  final String usuario; // userId o nombre del usuario
  final double? lat;
  final double? lng;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attendance({
    this.id,
    required this.fecha,
    required this.usuario,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'usuario': usuario,
      'ubicacion': lat != null && lng != null ? {'lat': lat, 'lng': lng} : null,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    // Appwrite devuelve campos especiales como $id, $createdAt, etc.
    final data = Map<String, dynamic>.from(map['\$data'] ?? map); // por si envías el objeto directo
    String? id = map['\$id'] ?? map['id'];
    DateTime? createdAt = map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null;
    DateTime? updatedAt = map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null;
    final ubic = data['ubicacion'];
    double? lat = ubic != null ? (ubic['lat']?.toDouble()) : null;
    double? lng = ubic != null ? (ubic['lng']?.toDouble()) : null;

    return Attendance(
      id: id,
      fecha: DateTime.parse(data['fecha']),
      usuario: data['usuario'],
      lat: lat,
      lng: lng,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
