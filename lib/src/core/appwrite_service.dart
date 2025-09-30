import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../models/attendance.dart';
import 'constants.dart';

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint(APPWRITE_ENDPOINT)
    ..setProject(APPWRITE_PROJECT_ID);

  static final Databases databases = Databases(client);

  // Crear documento de asistencia
  static Future<models.Document> createAttendance(Attendance a) async {
    final userId = a.usuario; // Debe ser el userId real de Appwrite

    final doc = await databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: ID.unique(),
      data: a.toMap(), // ahora devuelve {fecha, usuario, lat, lng}
      permissions: [
        Permission.read(Role.any()), // Solo el dueño puede leer
        Permission.update(Role.user(userId)), // Solo el dueño puede actualizar
        Permission.delete(Role.user(userId)), // Solo el dueño puede borrar
      ],
    );
    return doc;
  }

  // Listar asistencias de un usuario
  static Future<List<models.Document>> listUserAttendances(
    String userId,
  ) async {
    final res = await databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      queries: [Query.equal('usuario', userId)],
    );
    return res.documents;
  }

  // Actualizar asistencia
  static Future<models.Document> updateAttendance(
    String docId,
    Attendance a,
  ) async {
    final userId = a.usuario;

    final doc = await databases.updateDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: docId,
      data: a.toMap(), // actualiza con {fecha, usuario, lat, lng}
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
    return doc;
  }
}
