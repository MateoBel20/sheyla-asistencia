class Attendance {
  final String? id;
  final DateTime fecha;
  final String usuario;
  final double? lat;
  final double? lng;
  final String? fotoId; // 👈 Nuevo campo
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attendance({
    this.id,
    required this.fecha,
    required this.usuario,
    this.lat,
    this.lng,
    this.fotoId, // 👈
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'usuario': usuario,
      'lat': lat,
      'lng': lng,
      'fotoId': fotoId, // 👈
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    String? id = map['\$id'] ?? map['id'];
    DateTime? createdAt = map['\$createdAt'] != null
        ? DateTime.parse(map['\$createdAt'])
        : null;
    DateTime? updatedAt = map['\$updatedAt'] != null
        ? DateTime.parse(map['\$updatedAt'])
        : null;

    return Attendance(
      id: id,
      fecha: DateTime.parse(map['fecha']),
      usuario: map['usuario'],
      lat: map['lat'] != null ? (map['lat'] as num).toDouble() : null,
      lng: map['lng'] != null ? (map['lng'] as num).toDouble() : null,
      fotoId: map['fotoId'], // 👈
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
