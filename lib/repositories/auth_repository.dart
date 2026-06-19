import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Future<void> _createUserInFirestore(User user, {String? name}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final docSnap = await userRef.get();

    if (!docSnap.exists) {
      await userRef.set({
        'id': user.uid,
        'displayName': name ?? user.displayName ?? '',
        'email': user.email,
        'phoneNumber': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Solo actualizamos campos si la auth de Firebase provee datos nuevos que no teníamos,
      // o simplemente actualizamos el email por seguridad. No sobreescribir teléfono.
      final updates = <String, dynamic>{};
      if (user.email != null) updates['email'] = user.email;
      if (name != null && name.isNotEmpty) {
        updates['displayName'] = name;
      } else if (user.displayName != null &&
          user.displayName!.isNotEmpty &&
          (docSnap.data()?['displayName'] ?? '').isEmpty) {
        updates['displayName'] = user.displayName;
      }
      if (user.photoURL != null &&
          user.photoURL!.isNotEmpty &&
          (docSnap.data()?['photoUrl'] ?? '').isEmpty) {
        updates['photoUrl'] = user.photoURL;
      }

      if (updates.isNotEmpty) {
        await userRef.update(updates);
      }
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> updateProfileData(String name, String phone) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    if (name.isNotEmpty && name != user.displayName) {
      await user.updateDisplayName(name);
    }

    await _firestore.collection('users').doc(user.uid).set({
      'displayName': name,
      'phoneNumber': phone,
    }, SetOptions(merge: true));
  }

  Future<void> updateProfileImage(Uint8List imageBytes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Convert image to Base64 and construct data URL
    final base64String = base64Encode(imageBytes);
    final url = 'data:image/jpeg;base64,$base64String';

    await _firestore.collection('users').doc(user.uid).set({
      'photoUrl': url,
    }, SetOptions(merge: true));
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'El usuario ha sido deshabilitado.';
      case 'user-not-found':
        return 'No se encontró un usuario con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return 'El correo ya está en uso por otra cuenta.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta de nuevo más tarde.';
      default:
        return 'Ocurrió un error inesperado. Intenta nuevamente.';
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    if (user.email == null) {
      throw 'El usuario no tiene un correo asignado o usa Google Sign-In';
    }

    final isGoogleSignIn = user.providerData.any((p) => p.providerId == 'google.com');
    if (isGoogleSignIn) {
      throw 'Los usuarios de Google deben cambiar su contraseña desde su cuenta de Google.';
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw 'La contraseña actual es incorrecta.';
      }
      throw _handleAuthException(e);
    }
  }

  Future<void> sendPasswordReset() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    if (user.email == null) throw Exception('Usuario sin correo electrónico');

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Actualizar el displayName con el nombre ingresado
      await credential.user?.updateDisplayName(name);

      if (credential.user != null) {
        await _createUserInFirestore(credential.user!, name: name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createUserInFirestore(userCredential.user!);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
