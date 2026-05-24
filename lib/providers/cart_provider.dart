import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/cart_repository.dart';
import '../providers/auth_provider.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CartRepository(firestore);
});

final cartStreamProvider = StreamProvider<Cart?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(cartRepositoryProvider).getCartStream(user.uid);
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    // Escuchar los cambios del servidor en tiempo real
    ref.listen<AsyncValue<Cart?>>(cartStreamProvider, (previous, next) {
      next.whenData((cart) {
        if (cart != null) {
          state = cart.items;
        } else {
          state = [];
        }
      });
    });

    final cartAsync = ref.watch(cartStreamProvider);
    return cartAsync.value?.items ?? [];
  }

  Future<void> addItem(CartItem item) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final currentItems = List<CartItem>.from(state);
    final index = currentItems.indexWhere((i) => i.productId == item.productId);

    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(
        quantity: currentItems[index].quantity + item.quantity,
      );
    } else {
      currentItems.add(item);
    }

    // Actualización optimista local
    state = currentItems;
    await ref.read(cartRepositoryProvider).updateCart(user.uid, currentItems);
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final currentItems = List<CartItem>.from(state);
    final index = currentItems.indexWhere((i) => i.productId == productId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index] = currentItems[index].copyWith(quantity: newQuantity);
      }
      // Actualización optimista local
      state = currentItems;
      await ref.read(cartRepositoryProvider).updateCart(user.uid, currentItems);
    }
  }

  Future<void> removeItem(String productId) async {
    await updateQuantity(productId, 0);
  }

  Future<void> clear() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = [];
    await ref.read(cartRepositoryProvider).clearCart(user.uid);
  }
}

// Proveedor que expone el carrito (gestiona estado local + servidor)
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

// Proveedor derivado para el subtotal original
final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (total, item) => total + (item.unitPrice * item.quantity));
});

// Proveedor derivado para el descuento total
final cartDiscountProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (total, item) => total + (item.discountValue * item.quantity));
});

// Proveedor derivado para el total real
final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final discount = ref.watch(cartDiscountProvider);
  return subtotal - discount;
});
