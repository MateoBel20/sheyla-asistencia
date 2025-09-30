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
    final doc = await databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: ID.unique(),
      data: a.toMap(),
      permissions: [
        Permission.read(Role.user(a.usuario)),   // Solo el usuario puede leer su asistencia
        Permission.update(Role.user(a.usuario)), // Solo el usuario puede actualizar su asistencia
        Permission.delete(Role.user(a.usuario)), // Solo el usuario puede borrar su asistencia
      ],
    );
    return doc;
  }

  // Listar asistencias de un usuario
  static Future<List<models.Document>> listUserAttendances(String userId) async {
    final res = await databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      queries: [
        Query.equal('usuario', userId),
      ],
    );
    return res.documents;
  }

  // Actualizar asistencia
  static Future<models.Document> updateAttendance(
    String docId,
    Map<String, dynamic> data,
    String userId,
  ) async {
    final doc = await databases.updateDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_COLLECTION_ID,
      documentId: docId,
      data: data,
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
    return doc;
  }
}
