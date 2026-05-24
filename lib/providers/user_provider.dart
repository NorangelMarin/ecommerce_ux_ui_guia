import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

final userProvider = Provider<User?>((ref) {
  // Simulación de usuario obtenido de la base de datos
  return User(
    id: 'usr_123',
    name: 'Juan Pérez',
    email: 'juan.perez@correo.unimet.edu.ve',
  );
});
