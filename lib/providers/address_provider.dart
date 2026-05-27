import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/address_repository.dart';
import '../providers/auth_provider.dart';
import '../models/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AddressRepository(firestore);
});

final userAddressesProvider = StreamProvider<List<Address>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(addressRepositoryProvider);
  return repo.getUserAddresses(user.uid);
});
