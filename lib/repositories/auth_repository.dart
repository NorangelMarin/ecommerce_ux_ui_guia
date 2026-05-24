import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Future<void> _createUserInFirestore(User user, {String? name}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.set({
      'id': user.uid,
      'displayName': name ?? user.displayName ?? '',
      'email': user.email,
      'phoneNumber': user.phoneNumber ?? '',
      'photoUrl': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
    final uploadTask = ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await _firestore.collection('users').doc(user.uid).set({
      'photoUrl': url,
    }, SetOptions(merge: true));
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    if (user.email == null) throw Exception('El usuario no tiene un correo asignado o usa Google Sign-In');

    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw 'La contraseña actual es incorrecta.';
      }
      throw e.message ?? 'Ocurrió un error al cambiar la contraseña';
    }
  }

  Future<void> sendPasswordReset() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    if (user.email == null) throw Exception('Usuario sin correo electrónico');
    
    await _auth.sendPasswordResetEmail(email: user.email!);
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Ocurrió un error en la autenticación';
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      // Actualizar el displayName con el nombre ingresado
      await credential.user?.updateDisplayName(name);
      
      if (credential.user != null) {
        await _createUserInFirestore(credential.user!, name: name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Ocurrió un error al registrar el usuario';
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

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
      throw e.message ?? 'Error en la autenticación con Google';
    } catch (e) {
      throw 'Error desconocido: $e';
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
