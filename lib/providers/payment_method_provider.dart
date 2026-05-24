import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/payment_method_repository.dart';
import '../providers/auth_provider.dart';
import '../models/payment_method.dart';

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PaymentMethodRepository(firestore);
});

final userPaymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(paymentMethodRepositoryProvider);
  return repo.getUserPaymentMethods(user.uid);
});
