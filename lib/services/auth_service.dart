/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  static Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // REGISTRO
  // ─────────────────────────────────────────────
  static Future<bool> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(name);
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // CERRAR SESIÓN
  // ─────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // USUARIO ACTUAL
  // ─────────────────────────────────────────────
  static User? get currentUser {
    return _auth.currentUser;
  }

  // ─────────────────────────────────────────────
  // ¿SESION ACTIVA?
  // ─────────────────────────────────────────────
  static bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  // ─────────────────────────────────────────────
  // OBTENER NOMBRE / EMAIL
  // ─────────────────────────────────────────────
  static String getUserName() {
    final user = _auth.currentUser;

    if (user == null) return "Usuario";

    if (user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    return user.email ?? "Usuario";
  }
}
/*══════════════════════════════════════════════ Un código de: Joseph Ubaldo Trejo Hernandez ══════════════════════════════════════════════*/
