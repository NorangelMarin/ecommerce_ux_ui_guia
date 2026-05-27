import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

enum CardType { vertical, horizontal, carrito }

class ProductCard extends StatelessWidget {
  final CardType type;
  final String title;
  final String price;
  final String category;
  final String imageUrl;
  final VoidCallback? onCartPressed;
  final int quantity; // Solo para carrito
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onDelete;
  final String? discount; // Ejemplo: "20% OFF"
  final String? originalPrice; // Monto tachado (ej: "$ 15.00")
  final VoidCallback? onTap; // Para ir al detalle
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const ProductCard({
    super.key,
    required this.type,
    required this.title,
    required this.price,
    this.category = 'CATEGORÍA',
    this.imageUrl = '',
    this.onCartPressed,
    this.quantity = 1,
    this.onIncrement,
    this.onDecrement,
    this.onDelete,
    this.discount,
    this.originalPrice,
    this.onTap,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CardType.vertical:
        return _buildVerticalCard(context);
      case CardType.horizontal:
        return _buildHorizontalCard(context);
      case CardType.carrito:
        return _buildCarritoCard(context);
    }
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: AppColors.of(context).fondoTarjetas,
      child: Center(
        child: Icon(Icons.shopping_bag, color: Colors.grey, size: 60),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Producto: $title, Precio: $price, Categoría: $category',
      container: true,
      child: GuideWrapper(
        title: 'tarjeta_de_producto_ley_de'.tr(),
        description:
            'Los elementos relacionados (imagen, precio, título) están agrupados, facilitando el escaneo visual. El área interactiva abarca toda la tarjeta para evitar toques fallidos en móviles.',
        alignment: Alignment.topRight,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: AppColors.of(context).fondoTarjetas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: _buildImagePlaceholder(context),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.of(context).sombras,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.of(context).textoPrincipal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            price,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.of(context).verdeSaman,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap:
                          onCartPressed ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title añadido al carrito'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.of(context).azulSistemas,
                              ),
                            );
                          },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.of(context).naranjaUnimet,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'aadir_al_carrito'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.of(context).textoPrincipal,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Producto: $title, Precio: $price',
      container: true,
      child: GuideWrapper(
        title: 'tarjeta_de_lista_contraste_y'.tr(),
        description:
            'El diseño horizontal maximiza el espacio vertical en listas largas. El precio resalta en verde para indicar disponibilidad financiera rápida, crucial en el mercado local.',
        alignment: Alignment.topRight,
        child: Container(
          width: 280, // Ancho fijo para scroll horizontal
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.of(context).fondoTarjetas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: double.infinity,
                        child: _buildImagePlaceholder(context),
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).naranjaUnimet,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discount!,
                            style: TextStyle(
                              color: AppColors.of(context).fondoTarjetas,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              category.toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.of(context).sombras,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.of(context).textoPrincipal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              price,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.of(context).verdeSaman,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap:
                            onFavoritePressed ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$title añadido a la lista de deseos',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.of(context).naranjaUnimet,
                                ),
                              );
                            },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.of(context).naranjaUnimet,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'aadir_a_lista_de_deseos'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.of(context).textoPrincipal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarritoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          '${'producto_en_carrito'.tr()}: $title, ${'cantidad'.tr()}: $quantity, ${'precio_total'.tr()}: $price',
      container: true,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.of(context).blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen — tap navega al detalle
            GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 88,
                  height: 88,
                  color: AppColors.of(context).fondoTarjetas,
                  child: Image.network(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://images.unsplash.com/photo-1593998066526-65fcab3021a2?auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.of(context).fondoTarjetas,
                      child: Icon(
                        Icons.shopping_bag,
                        size: 40,
                        color: AppColors.of(context).sombras,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            // Info Central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  // Título — tap navega al detalle
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textoPrincipal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (discount != null && discount!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.of(context).error,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.of(context).verdeSaman,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (originalPrice != null &&
                          originalPrice!.isNotEmpty) ...[
                        SizedBox(width: 8),
                        Text(
                          originalPrice!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.of(context).sombras,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  // Pastilla de cantidad [- 1 +]
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.of(context).sombras.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onDecrement,
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.of(context).sombras,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '$quantity',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.of(context).textoPrincipal,
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: onIncrement,
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.of(context).sombras,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap:
                        onFavoritePressed ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$title${'aadido_a_la_lista_de_deseos'.tr()}',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.of(context).naranjaUnimet,
                            ),
                          );
                        },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: AppColors.of(context).naranjaUnimet,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isFavorite
                              ? 'en_lista_de_deseos'.tr()
                              : 'aadir_a_lista_de_deseos'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.of(context).naranjaUnimet,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Botón Eliminar (X naranja)
            IconButton(
              icon: Icon(Icons.close, color: AppColors.of(context).naranjaUnimet, size: 20),
              onPressed: onDelete,
              constraints: BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
