import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/wishlist_repository.dart';
import '../providers/auth_provider.dart';
import '../models/wishlist.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return WishlistRepository(firestore);
});

final wishlistStreamProvider = StreamProvider<Wishlist?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(wishlistRepositoryProvider).getWishlistStream(user.uid);
});

class WishlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    ref.listen<AsyncValue<Wishlist?>>(wishlistStreamProvider, (previous, next) {
      next.whenData((wishlist) {
        if (wishlist != null) {
          state = wishlist.productIds;
        } else {
          state = [];
        }
      });
    });

    final wishlistAsync = ref.watch(wishlistStreamProvider);
    return wishlistAsync.value?.productIds ?? [];
  }

  Future<void> toggleProduct(String productId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final currentIds = List<String>.from(state);
    final isAdding = !currentIds.contains(productId);

    if (isAdding) {
      currentIds.add(productId);
    } else {
      currentIds.remove(productId);
    }

    // Actualización optimista
    state = currentIds;
    await ref.read(wishlistRepositoryProvider).toggleProduct(user.uid, productId, isAdding);
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<String>>(() {
  return WishlistNotifier();
});
