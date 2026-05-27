import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/cart_item.dart';
import '../../widgets/floating_chat_button.dart';
import '../../providers/category_provider.dart';
import '../../providers/guide_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final productsAsync = ref.watch(productsProvider);
    final wishlistIds = ref.watch(wishlistProvider);
    final categoriesData = ref.watch(categoriesProvider);
    final isGuideMode = ref.watch(guideProvider);

    // Mapa id -> nombre para resolver IDs de categoría almacenados en productos
    final Map<String, String> categoryIdToName = {
      for (final cat in (categoriesData.value ?? [])) cat.id: cat.name,
    };

    String resolvedCategoryName(List<String> categories) {
      if (categories.isEmpty) return 'General';
      final first = categories.first;
      return categoryIdToName[first] ?? first;
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      floatingActionButton: FloatingChatButton(),
      appBar: TopNavigationBar(
        title: 'ecommerce_uxui_guía'.tr(),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        actionIcon: Icons.shopping_cart_outlined,
        onActionPressed: () => context.push('/cart'),
        extraActions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.of(context).naranjaUnimet),
            onPressed: () => context.push('/catalog'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('bienvenido'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.of(context).sombras,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        user?.displayName ?? 'Invitado',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.of(context).textoPrincipal,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isGuideMode ? 'modo_guia_on'.tr() : 'modo_guia_off'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.of(context).sombras,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 4),
                      Switch(
                        value: isGuideMode,
                        activeThumbColor: AppColors.of(context).naranjaUnimet,
                        activeTrackColor: AppColors.of(context).naranjaUnimet.withOpacity(
                          0.3,
                        ),
                        inactiveThumbColor: AppColors.of(context).sombras.withOpacity(0.5),
                        inactiveTrackColor: AppColors.of(context).sombras.withOpacity(0.15),
                        onChanged: (value) {
                          ref.read(guideProvider.notifier).toggle();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bento Grid Categorías
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GuideWrapper(
                title: 'bento_grid_de_categorías'.tr(),
                description:
                    'Este diseño tipo "bento" organiza las categorías de forma visualmente atractiva y fácil de tocar (Ley de Fitts). Los bloques de color sólido con iconos grandes ayudan a la identificación rápida y reducen la carga cognitiva para usuarios móviles en Caracas que buscan agilidad en sus compras.',
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      // Categoría Izquierda (Grande)
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              context.push('/catalog', extra: 'Laptops'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.of(context).verdeSaman,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.laptop,
                                  color: Colors.white,
                                  size: 36,
                                ), // Categoría real
                                Text('laptops'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Categorías Derecha (Apiladas)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push(
                                  '/catalog',
                                  extra: 'Celulares',
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.of(context).naranjaUnimet,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_android,
                                        color: Colors.white,
                                        size: 24,
                                      ), // Categoría real
                                      SizedBox(width: 8),
                                      Text('celulares'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    context.push('/catalog', extra: 'Audio'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.of(context).azulSistemas,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.headphones,
                                        color: Colors.white,
                                        size: 24,
                                      ), // Categoría real
                                      SizedBox(width: 8),
                                      Text('audio'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Productos destacados
            // Productos destacados
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GuideWrapper(
                    title: 'productos_destacados'.tr(),
                    description:
                        'Colocar los productos más importantes en la pantalla inicial reduce el esfuerzo de búsqueda. Además, el scroll horizontal mantiene limpio el diseño vertical y aprovecha la exploración natural en pantallas táctiles.',
                    alignment: Alignment.topRight,
                    child: Text('productos_destacados'.tr(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textoPrincipal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/catalog'),
                    child: Text('ver_todo'.tr(),
                      style: TextStyle(
                        color: AppColors.of(context).naranjaUnimet,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 236,
              child: productsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.of(context).naranjaUnimet,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text('error_general'.tr(args: [err.toString()]), style: TextStyle(color: Colors.red),
                  ),
                ),
                data: (products) {
                  final featuredProducts = products
                      .where((p) => p.isFeatured)
                      .toList();

                  if (featuredProducts.isEmpty) {
                    return Center(
                      child: Text('aade_productos_destacados'.tr(),
                        style: TextStyle(color: AppColors.of(context).sombras),
                      ),
                    );
                  }
                  return ListView.separated(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length > 4
                        ? 4
                        : featuredProducts.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return ProductCard(
                        type: CardType.vertical,
                        title: product.title,
                        price: '\$ ${product.price.toStringAsFixed(2)}',
                        category: resolvedCategoryName(product.categories),
                        imageUrl: product.imageUrl,
                        discount: product.discount,
                        isFavorite: wishlistIds.contains(product.id),
                        onFavoritePressed: () => ref
                            .read(wishlistProvider.notifier)
                            .toggleProduct(product.id),
                        onCartPressed: () {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.title} añadido al carrito',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.of(context).azulSistemas,
                            ),
                          );
                        },
                        onTap: () =>
                            context.push('/product_detail/${product.id}'),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Ofertas especiales
            // Ofertas especiales
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GuideWrapper(
                  title: 'ofertas_especiales_aversión_a_la'.tr(),
                  description:
                      'Mostrar claramente los descuentos apela al principio psicológico de "aversión a la pérdida". Los usuarios perciben mayor valor al ver cuánto están ahorrando, motivando la compra por oportunidad.',
                  alignment: Alignment.topRight,
                  child: Text('ofertas_especiales'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: productsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.of(context).naranjaUnimet,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text('error_general'.tr(args: [err.toString()]), style: TextStyle(color: Colors.red),
                  ),
                ),
                data: (products) {
                  // Filtrar productos que tengan descuento
                  final offerProducts = products
                      .where(
                        (p) => p.discount != null && p.discount!.isNotEmpty,
                      )
                      .toList();

                  if (offerProducts.isEmpty) {
                    return Center(
                      child: Text('aade_productos_con_descuento'.tr(),
                        style: TextStyle(color: AppColors.of(context).sombras),
                      ),
                    );
                  }
                  return ListView.separated(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: offerProducts.length > 3
                        ? 3
                        : offerProducts.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final product = offerProducts[index];
                      return ProductCard(
                        type: CardType.horizontal,
                        title: product.title,
                        price: '\$ ${product.price.toStringAsFixed(2)}',
                        category: resolvedCategoryName(product.categories),
                        imageUrl: product.imageUrl,
                        discount: product.discount,
                        isFavorite: wishlistIds.contains(product.id),
                        onFavoritePressed: () => ref
                            .read(wishlistProvider.notifier)
                            .toggleProduct(product.id),
                        onTap: () =>
                            context.push('/product_detail/${product.id}'),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 32), // Espaciado inferior extra
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }
}
