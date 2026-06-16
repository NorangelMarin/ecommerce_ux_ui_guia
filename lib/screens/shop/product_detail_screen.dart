import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/guide_wrapper.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/cart_item.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final wishlistIds = ref.watch(wishlistProvider);
    final reviewsAsync = ref.watch(reviewsProvider(productId));
    final hasPurchased = ref.watch(hasPurchasedProvider(productId));
    final hasReviewed =
        ref.watch(hasReviewedProvider(productId)).value ?? false;
    final currentUser = ref.watch(authStateProvider).value;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? [];

    String getCategoryName(String categoryId) {
      try {
        return categories.firstWhere((c) => c.id == categoryId).name;
      } catch (e) {
        return categoryId;
      }
    }

    // Buscar el producto. Si aún no carga, mostramos un loader.
    if (productsAsync.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.of(context).naranjaUnimet),
        ),
      );
    }

    final allProducts = productsAsync.value ?? [];
    final productIndex = allProducts.indexWhere((p) => p.id == productId);

    if (productIndex == -1) {
      return Scaffold(
        appBar: TopNavigationBar(
          title: 'detalle_producto'.tr(),
          leadingIcon: Icons.arrow_back_ios_new,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(child: Text('producto_no_encontrado'.tr())),
      );
    }

    final product = allProducts[productIndex];
    final isFavorite = wishlistIds.contains(productId);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      appBar: TopNavigationBar(
        titleWidget: Text('detalle_del_producto'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.arrow_back_ios_new, // Flecha iOS como en el diseño
        onLeadingPressed: () => context.pop(),
        actionIcon: isFavorite ? Icons.favorite : Icons.favorite_border,
        onActionPressed: () {
          final isAdding = !wishlistIds.contains(productId);
          ref.read(wishlistProvider.notifier).toggleProduct(productId);
          if (isAdding) {
            CustomNotification.show(context, message: '${product.title} añadido a favoritos', type: NotificationType.success);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 280,
                      child: product.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.of(context).fondoTarjetas,
                                child: Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.of(context).sombras,
                                ),
                              ),
                            )
                          : Image.network(
                              product.imageUrl.isNotEmpty
                                  ? product.imageUrl
                                  : 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.of(context).fondoTarjetas,
                                child: Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.of(context).sombras,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).azulSistemas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GuideWrapper(
                        id: 'detail_zoom',
                        title: 'Reducción de incertidumbre',
                        description: 'Permitir visualizar el producto en detalle reduce la fricción en la decisión de compra, ya que compensa la imposibilidad física de examinar el producto.',
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => _openImageZoom(
                            context,
                            product.imageUrl.isNotEmpty
                                ? product.imageUrl
                                : 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.of(context).verdeSaman,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (product.discount != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).naranjaUnimet,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.discount!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Descripción
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('descripcin'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: AppColors.of(context).azulSistemas,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description ??
                        'No hay descripción disponible para este producto. Próximamente agregaremos más detalles.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            GuideWrapper(
              title: 'llamado_a_la_acción_primario'.tr(),
              description:
                  'El botón principal debe destacar con un color cálido y un tamaño amplio. Centrarlo asegura que sea el elemento interactivo más prominente, optimizando la tasa de conversión en móviles.',
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.0),
                child: CustomButton(
                  text: 'aadir_al_carrito'.tr(),
                  color: ButtonColor.naranja,
                  icon: Icons.add_shopping_cart,
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .addItem(
                          CartItem(
                            productId: product.id,
                            title: product.title,
                            unitPrice: product.price,
                            imageUrl: product.imageUrl,
                            quantity: 1,
                            discountValue: product.discountPercentage > 0
                                ? (product.price *
                                      (product.discountPercentage / 100))
                                : 0.0,
                          ),
                        );
                    CustomNotification.show(context, message: '${product.title} ${'anadido_al_carrito'.tr()}', type: NotificationType.success);
                  },
                ),
              ),
            ),

            SizedBox(height: 24),

            // Especificaciones Técnicas
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.of(context).fondoTarjetas,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('especificaciones_tcnicas'.tr(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.of(context).textoPrincipal,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (product.specs.isNotEmpty) ...[
                      ...product.specs.entries.toList().asMap().entries.map((
                        entry,
                      ) {
                        final isLast = entry.key == product.specs.length - 1;
                        return _buildSpecRow(context, 
                          entry.value.key,
                          entry.value.value,
                          isLast: isLast,
                        );
                      }),
                    ] else ...[
                      _buildSpecRow(context, 'Categoría principal', getCategoryName(product.category)),
                      if (product.categories.length > 1)
                        _buildSpecRow(context, 
                          'otras_categorías'.tr(),
                          product.categories.skip(1).map(getCategoryName).join(', '),
                        ),
                      _buildSpecRow(context, 
                        'ID de referencia',
                        product.id,
                        isLast: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Reseñas
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('reseas'.tr(),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: AppColors.of(context).azulSistemas,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (product.totalResenas > 0) ...[
                            Icon(
                              Icons.star,
                              color: AppColors.of(context).naranjaUnimet,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${product.ratingPromedio.toStringAsFixed(1)} (${product.totalResenas})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.of(context).sombras,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (hasPurchased && !hasReviewed)
                        TextButton.icon(
                          onPressed: () =>
                              _showReviewSheet(context, ref, currentUser),
                          icon: Icon(
                            Icons.rate_review,
                            size: 16,
                            color: AppColors.of(context).naranjaUnimet,
                          ),
                          label: Text('escribir_resea'.tr(),
                            style: TextStyle(
                              color: AppColors.of(context).naranjaUnimet,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        )
                      else if (hasPurchased && hasReviewed)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).verdeSaman.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: AppColors.of(context).verdeSaman,
                              ),
                              SizedBox(width: 4),
                              Text('ya_reseaste'.tr(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.of(context).verdeSaman,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  if (product.totalResenas > 0)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).fondoTarjetas,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            product.ratingPromedio.toStringAsFixed(1),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).textoPrincipal,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    if (i < product.ratingPromedio.floor()) {
                                      return Icon(
                                        Icons.star,
                                        color: AppColors.of(context).naranjaUnimet,
                                        size: 18,
                                      );
                                    } else if (i < product.ratingPromedio) {
                                      return Icon(
                                        Icons.star_half,
                                        color: AppColors.of(context).naranjaUnimet,
                                        size: 18,
                                      );
                                    } else {
                                      return Icon(
                                        Icons.star_border,
                                        color: AppColors.of(context).sombras.withValues(
                                          alpha: 0.4,
                                        ),
                                        size: 18,
                                      );
                                    }
                                  }),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'basado_en_resenas'.tr(args: [product.totalResenas.toString(), product.totalResenas == 1 ? '' : 's']),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.of(context).sombras,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 12),

                  // Lista de reseñas desde Firestore
                  reviewsAsync.when(
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.of(context).naranjaUnimet,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      'Error al cargar reseñas: $e',
                      style: TextStyle(color: Colors.red),
                    ),
                    data: (reviews) {
                      if (reviews.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).fondoTarjetas,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                color: AppColors.of(context).sombras.withValues(alpha: 0.5),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text('an_no_hay_reseas_para_este_producto'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.of(context).sombras,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: reviews.map((review) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.of(context).fondoTarjetas,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: review.userPhotoUrl.isNotEmpty
                                        ? Image.network(
                                            review.userPhotoUrl,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _avatarFallback(context, 
                                                  review.userName,
                                                ),
                                          )
                                        : _avatarFallback(context, review.userName),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Nombre + fecha
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              review.userName,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                            if (review.createdAt != null)
                                              Text(
                                                _formatDate(review.createdAt!),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.of(context).sombras,
                                                      fontSize: 10,
                                                    ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        // Estrellas
                                        Row(
                                          children: List.generate(5, (i) {
                                            if (i < review.rating.floor()) {
                                              return Icon(
                                                Icons.star,
                                                color: AppColors.of(context).naranjaUnimet,
                                                size: 13,
                                              );
                                            } else if (i < review.rating) {
                                              return Icon(
                                                Icons.star_half,
                                                color: AppColors.of(context).naranjaUnimet,
                                                size: 13,
                                              );
                                            } else {
                                              return Icon(
                                                Icons.star_border,
                                                color: AppColors.of(context).sombras
                                                    .withValues(alpha: 0.4),
                                                size: 13,
                                              );
                                            }
                                          }),
                                        ),
                                        SizedBox(height: 8),
                                        // Comentario
                                        Text(
                                          review.comment,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: AppColors.of(context).textoPrincipal,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 40), // Espaciado final
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String key, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.of(context).textoPrincipal,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: AppColors.of(context).sombras),
            ),
          ),
        ],
      ),
    );
  }

  void _openImageZoom(BuildContext context, String imageUrl) {
    final TransformationController transformController =
        TransformationController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar zoom',
      barrierColor: Colors.black87,
      transitionDuration: Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim, secondaryAnim) {
        return SafeArea(
          child: Stack(
            children: [
              // Visor con zoom interactivo
              Center(
                child: GestureDetector(
                  onDoubleTap: () {
                    if (transformController.value != Matrix4.identity()) {
                      transformController.value = Matrix4.identity();
                    } else {
                      transformController.value = Matrix4.identity()
                        ..scale(2.5);
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: transformController,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: Hero(
                      tag: 'product_image_$imageUrl',
                      child: imageUrl.startsWith('assets/')
                          ? Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Hint zoom
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white70, size: 14),
                        SizedBox(width: 6),
                        Text('pellizca_o_toca_dos_veces_para_hacer_zoo'.tr(),
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => transformController.dispose());
  }

  /// Fallback de avatar: muestra la inicial del nombre sobre fondo gris
  Widget _avatarFallback(BuildContext context, String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.of(context).azulSistemas.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).azulSistemas,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Formatea DateTime como "dd/mm/aaaa"
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Bottom sheet para escribir una reseña
  void _showReviewSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic currentUser,
  ) {
    double selectedRating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.rate_review,
                        color: AppColors.of(context).naranjaUnimet,
                      ),
                      SizedBox(width: 8),
                      Text('escribir_resea'.tr(),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).textoPrincipal,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Selector de estrellas
                  Text('tu_calificacin'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final starValue = i + 1.0;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedRating = starValue),
                        child: Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: i < selectedRating
                                ? AppColors.of(context).naranjaUnimet
                                : AppColors.of(context).sombras,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (selectedRating > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        [
                          '',
                          'Muy malo',
                          'Malo',
                          'Regular',
                          'Bueno',
                          'Excelente',
                        ][selectedRating.toInt()],
                        style: TextStyle(
                          color: AppColors.of(context).naranjaUnimet,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),

                  Text('tu_comentario'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'escribe_tus_comentarios_aquí'.tr(),
                      hintStyle: TextStyle(
                        color: AppColors.of(context).sombras.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppColors.of(context).fondoTarjetas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.of(context).naranjaUnimet,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).naranjaUnimet,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (selectedRating == 0) {
                                CustomNotification.show(context, message: 'por_favor_selecciona_una_calificacin'.tr(), type: NotificationType.info);
                                return;
                              }
                              if (commentController.text.trim().isEmpty) {
                                CustomNotification.show(context, message: 'por_favor_escribe_un_comentario'.tr(), type: NotificationType.info);
                                return;
                              }
                              setSheetState(() => isSubmitting = true);
                              try {
                                await submitReview(
                                  productId: productId,
                                  userId: currentUser?.uid ?? '',
                                  userName:
                                      currentUser?.displayName ??
                                      currentUser?.email?.split('@').first ??
                                      'Usuario',
                                  userPhotoUrl: currentUser?.photoURL ?? '',
                                  rating: selectedRating,
                                  comment: commentController.text.trim(),
                                );
                                if (ctx.mounted) Navigator.of(ctx).pop();
                                if (context.mounted) {
                                  CustomNotification.show(context, message: 'resea_publicada_gracias_por_tu_opinin'.tr(), type: NotificationType.success);
                                }
                              } catch (e) {
                                setSheetState(() => isSubmitting = false);
                                if (context.mounted) {
                                  CustomNotification.show(context, message: 'Error al publicar: $e', type: NotificationType.error);
                                }
                              }
                            },
                      child: isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('publicar_resea'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
