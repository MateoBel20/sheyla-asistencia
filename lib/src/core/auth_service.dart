import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'constants.dart';

class AuthService {
  static final Client client = Client()
    ..setEndpoint(APPWRITE_ENDPOINT)
    ..setProject(APPWRITE_PROJECT_ID);

  static final Account account = Account(client);

  /// Registrar usuario con email + password
  static Future<models.User> register(String email, String password) async {
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
    );
    return user;
  }

  /// Iniciar sesión
  static Future<models.Session> login(String email, String password) async {
    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return session;
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  /// Obtener usuario actual (si está logueado)
  static Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (_) {
      return null; // No hay sesión activa
    }
  }
}
