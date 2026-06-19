import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../../providers/accessibility_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  // Filtros y Orden
  String _searchQuery = '';
  String _sortOrder = 'none'; // none, asc, desc
  String? _selectedCategory;
  double? _maxPrice;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        if (mounted) setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _searchController.text = val.recognizedWords;
                _searchQuery = val.recognizedWords;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
              });
            }
          },
        );
        if (mounted) {
          CustomNotification.show(context, message: 'escuchando_di_el_nombre_del'.tr(), type: NotificationType.info);
        }
      } else {
        if (mounted) {
          CustomNotification.show(context, message: 'reconocimiento_de_voz_no_disponible_o_pe'.tr(), type: NotificationType.info);
        }
      }
    } else {
      if (mounted) setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ordenar_por'.tr(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textoPrincipal,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('a_z'.tr()),
                trailing: _sortOrder == 'asc'
                    ? Icon(Icons.check, color: AppColors.of(context).naranjaUnimet)
                    : null,
                onTap: () {
                  setState(() => _sortOrder = 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('z_a'.tr()),
                trailing: _sortOrder == 'desc'
                    ? Icon(Icons.check, color: AppColors.of(context).naranjaUnimet)
                    : null,
                onTap: () {
                  setState(() => _sortOrder = 'desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('relevancia_por_defecto'.tr()),
                trailing: _sortOrder == 'none'
                    ? Icon(Icons.check, color: AppColors.of(context).naranjaUnimet)
                    : null,
                onTap: () {
                  setState(() => _sortOrder = 'none');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal(List<CategoryModel> categories) {
    String? tempCategory = _selectedCategory;
    double tempMaxPrice = _maxPrice ?? 2500.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'filtrar_resultados'.tr(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'categora'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: tempCategory,
                    dropdownColor: AppColors.of(context).blanco,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('todas_las_categorías'.tr()),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (val) => setModalState(() => tempCategory = val),
                  ),

                  SizedBox(height: 24),
                  Text(
                    '${'precio_maximo'.tr()}: \$${tempMaxPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  Slider(
                    value: tempMaxPrice,
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: AppColors.of(context).naranjaUnimet,
                    label: '\$${tempMaxPrice.toStringAsFixed(0)}',
                    onChanged: (val) => setModalState(() => tempMaxPrice = val),
                  ),

                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).naranjaUnimet,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = tempCategory;
                          _maxPrice = tempMaxPrice;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'aplicar_filtros'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessState = ref.watch(accessibilityProvider);
    final wishlistIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    // Mapa id -> nombre para resolver IDs de categoría almacenados en productos
    final Map<String, String> categoryIdToName = {
      for (final cat in (categoriesAsync.value ?? [])) cat.id: cat.name,
    };

    String resolvedCategoryName(List<String> categories) {
      if (categories.isEmpty) return 'general'.tr();
      final first = categories.first;
      return categoryIdToName[first] ?? first;
    }

    final allProducts = productsAsync.value ?? [];
    var wishlistProducts = allProducts.where((p) {
      if (!wishlistIds.contains(p.id)) return false;

      final categoryName = resolvedCategoryName(p.categories);

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(q);
        final matchesCategory = categoryName.toLowerCase().contains(q);
        final matchesDesc = (p.description ?? '').toLowerCase().contains(q);
        final matchesSpecs = p.specs.values.any(
          (v) => v.toLowerCase().contains(q),
        );
        if (!matchesTitle &&
            !matchesCategory &&
            !matchesDesc &&
            !matchesSpecs) {
          return false;
        }
      }

      if (_selectedCategory != null && categoryName != _selectedCategory) {
        return false;
      }
      if (_maxPrice != null && p.price > _maxPrice!) {
        return false;
      }
      return true;
    }).toList();

    if (_sortOrder == 'asc') {
      wishlistProducts.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortOrder == 'desc') {
      wishlistProducts.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
    }

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'lista_de_deseos'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null, // Abre el drawer nativamente
        actionIcon: Icons.shopping_cart_outlined,
        onActionPressed: () => context.push('/cart'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: GuideWrapper(
              id: 'wishlist_title',
              title: 'Artículos Guardados',
              description: 'La lista de deseos actúa como un puente entre el descubrimiento y la compra diferida. Permite al usuario guardar productos para decisiones futuras, mejorando la retención y la conversión a largo plazo.',
              child: Text(
                _searchQuery.isNotEmpty
                    ? '${'resultados_de'.tr()}"$_searchQuery"'
                    : _selectedCategory != null
                    ? '${'categora'.tr()}: $_selectedCategory'
                    : 'tus_productos_favoritos'.tr(),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textoPrincipal,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Buscador
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'buscar_en_favoritos'.tr(),
                prefixIcon: Icon(Icons.search, color: AppColors.of(context).sombras),
                suffixIcon: accessState.voiceSearch
                    ? IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? Colors.red
                              : AppColors.of(context).naranjaUnimet,
                          size: 20,
                        ),
                        onPressed: _listen,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.of(context).blanco,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.of(context).sombras.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.of(context).sombras.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.of(context).azulSistemas),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? '${'mostrando_resultados_de'.tr()}"$_searchQuery"'
                        : _selectedCategory != null
                        ? '${'mostrando_resultados_de'.tr()}"$_selectedCategory"'
                        : 'mostrando_articulos_guardados'.tr(
                            args: [wishlistProducts.length.toString()],
                          ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      height: 1.2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.of(context).azulSistemas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showFilterModal(categoriesAsync.value ?? []),
                        tooltip: 'Filtrar',
                        constraints: BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.of(context).azulSistemas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.sort,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showSortModal,
                        tooltip: 'Ordenar',
                        constraints: BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Cuadrícula de Productos Favoritos
          Expanded(
            child: wishlistProducts.isEmpty
                ? GuideWrapper(
                    title: 'estados_vacíos_empty_states'.tr(),
                    description:
                        'Los estados vacíos previenen la confusión. Un icono claro y un mensaje amigable aseguran al usuario que el sistema funciona correctamente, reduciendo la fricción.',
                    alignment: Alignment.topCenter,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: AppColors.of(context).sombras,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'an_no_tienes_favoritos'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.of(context).sombras,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent:
                          236, // Altura absoluta fija, soluciona el overflow/whitespace
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: wishlistProducts.length,
                    itemBuilder: (context, index) {
                      final product = wishlistProducts[index];
                      final card = ProductCard(
                        type: CardType.vertical,
                        title: product.title,
                        price: '\$ ${product.price.toStringAsFixed(2)}',
                        category: resolvedCategoryName(product.categories),
                        imageUrl: product.imageUrl,
                        isFavorite: true,
                        onFavoritePressed: () {
                          final isAdding = !wishlistIds.contains(product.id);
                          ref.read(wishlistProvider.notifier).toggleProduct(product.id);
                          if (isAdding) {
                            CustomNotification.show(context, message: '${product.title} añadido a favoritos', type: NotificationType.success);
                          }
                        },
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
                          CustomNotification.show(context, message: '${product.title} ${'anadido_al_carrito'.tr()}', type: NotificationType.success);
                        },
                        onTap: () =>
                            context.push('/product_detail/${product.id}'),
                      );
                      return card;
                    },
                  ),
          ),
        ],
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
}
