import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../../providers/accessibility_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CatalogScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  TextEditingController? _searchControllerRef;
  String _searchQuery = '';

  // Filtros y Orden
  String _sortOrder = 'none'; // none, asc, desc
  String? _selectedCategory;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
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
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        if (mounted) setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                if (_searchControllerRef != null) {
                  _searchControllerRef!.text = val.recognizedWords;
                  // Set cursor to the end of text
                  _searchControllerRef!.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchControllerRef!.text.length),
                  );
                }
              });
            }
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('escuchando_di_el_nombre_del'.tr()),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textoPrincipal,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reconocimiento de voz no disponible o permisos denegados.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textoPrincipal,
            ),
          );
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
                'Ordenar por',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoPrincipal,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('a_z'.tr()),
                trailing: _sortOrder == 'asc'
                    ? Icon(Icons.check, color: AppColors.naranjaUnimet)
                    : null,
                onTap: () {
                  setState(() => _sortOrder = 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('z_a'.tr()),
                trailing: _sortOrder == 'desc'
                    ? Icon(Icons.check, color: AppColors.naranjaUnimet)
                    : null,
                onTap: () {
                  setState(() => _sortOrder = 'desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('relevancia_por_defecto'.tr()),
                trailing: _sortOrder == 'none'
                    ? Icon(Icons.check, color: AppColors.naranjaUnimet)
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
                    'Filtrar resultados',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Categoría',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: tempCategory,
                    dropdownColor: AppColors.blanco,
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
                    'Precio Máximo: \$${tempMaxPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  Slider(
                    value: tempMaxPrice,
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: AppColors.naranjaUnimet,
                    label: '\$${tempMaxPrice.toStringAsFixed(0)}',
                    onChanged: (val) => setModalState(() => tempMaxPrice = val),
                  ),

                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranjaUnimet,
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
                        'Aplicar filtros',
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
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accessState = ref.watch(accessibilityProvider);
    final List<String> productNames =
        productsAsync.value?.map((p) => p.title).toList() ?? [];
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: SizedBox(
          height: 36, // Un poco más delgado que antes
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return Iterable<String>.empty();
              }
              return productNames.where((String option) {
                return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String selection) {
              setState(() {
                _searchQuery = selection;
              });
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
                  if (_searchControllerRef != textEditingController) {
                    _searchControllerRef = textEditingController;
                    _searchControllerRef!.addListener(() {
                      setState(() {
                        _searchQuery = _searchControllerRef!.text;
                      });
                    });
                  }
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'productos'.tr(),
                      hintStyle: TextStyle(
                        color: AppColors.sombras.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.sombras,
                        size: 20,
                      ),
                      suffixIcon: accessState.voiceSearch
                          ? IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red
                                    : AppColors.naranjaUnimet,
                                size: 20,
                              ),
                              onPressed: _listen,
                            )
                          : null,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.blanco,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.sombras.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.sombras.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.sombras.withValues(alpha: 0.1),
                    ),
                  ),
                  color: AppColors.blanco,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 250,
                      maxWidth:
                          MediaQuery.of(context).size.width -
                          120, // Ajuste aproximado del header
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: AppColors.sombras,
                                  size: 16,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: AppColors.textoPrincipal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null, // Abre el drawer nativamente
        actionIcon: Icons.shopping_cart_outlined,
        onActionPressed: () => context.push('/cart'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final productsAsync = ref.watch(productsProvider);
          final categoriesData = ref.watch(categoriesProvider);
          final wishlistIds = ref.watch(wishlistProvider);

          // Mapa id -> nombre para resolver IDs de categoría almacenados en productos
          final Map<String, String> categoryIdToName = {
            for (final cat in (categoriesData.value ?? [])) cat.id: cat.name,
          };

          // Helper: obtiene el nombre legible de la categoría principal del producto
          String resolvedCategoryName(List<String> categories) {
            if (categories.isEmpty) return 'General';
            final first = categories.first;
            // Si el valor ya parece un nombre (no un ID de Firestore), úsalo directamente
            return categoryIdToName[first] ?? first;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'Resultados de "$_searchQuery"'
                      : _selectedCategory != null
                      ? 'Categoría: $_selectedCategory'
                      : 'Todos los productos',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoPrincipal,
                    fontSize: 20,
                  ),
                ),
              ),

              // Fila de Resultados y Filtros
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        productsAsync.hasValue
                            ? (_searchQuery.isNotEmpty
                                  ? 'Mostrando resultados de "$_searchQuery"'
                                  : _selectedCategory != null
                                  ? 'Mostrando resultados de "$_selectedCategory"'
                                  : 'Mostrando todos los artículos')
                            : 'Cargando artículos...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.sombras,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GuideWrapper(
                      title: 'filtros_y_ordenamiento_control_del'.tr(),
                      description:
                          'Permitir que el usuario filtre y ordene el catálogo reduce la frustración al buscar productos específicos. El diseño compacto a la derecha se alinea con los patrones estándar y facilita el acceso al pulgar.',
                      alignment: Alignment.topRight,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.azulSistemas,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.tune,
                                color: AppColors.blanco,
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
                              color: AppColors.azulSistemas,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.sort,
                                color: AppColors.blanco,
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Cuadrícula de Productos
              Expanded(
                child: productsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.naranjaUnimet,
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error al cargar productos: $error',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  data: (products) {
                    var filteredProducts = products.where((p) {
                      final categoryName = resolvedCategoryName(p.categories);

                      // 1. Filtrar por búsqueda de texto (título, descripción, categoría o specs)
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        final matchesTitle = p.title.toLowerCase().contains(q);
                        final matchesCategory = categoryName
                            .toLowerCase()
                            .contains(q);
                        final matchesDesc = (p.description ?? '')
                            .toLowerCase()
                            .contains(q);
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

                      // 2. Filtrar por categoría (comparar nombre resuelto vs nombre seleccionado)
                      if (_selectedCategory != null &&
                          categoryName != _selectedCategory) {
                        return false;
                      }

                      // 3. Filtrar por precio máximo
                      if (_maxPrice != null && p.price > _maxPrice!) {
                        return false;
                      }

                      return true;
                    }).toList();

                    // 4. Aplicar ordenamiento
                    if (_sortOrder == 'asc') {
                      filteredProducts.sort(
                        (a, b) => a.title.toLowerCase().compareTo(
                          b.title.toLowerCase(),
                        ),
                      );
                    } else if (_sortOrder == 'desc') {
                      filteredProducts.sort(
                        (a, b) => b.title.toLowerCase().compareTo(
                          a.title.toLowerCase(),
                        ),
                      );
                    }

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No se encontraron productos para tu búsqueda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.sombras),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 236,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final displayCategory = resolvedCategoryName(
                          product.categories,
                        );
                        return ProductCard(
                          type: CardType.vertical,
                          title: product.title,
                          price: '\$ ${product.price.toStringAsFixed(2)}',
                          category: displayCategory,
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
                                    discountValue:
                                        product.discountPercentage > 0
                                        ? (product.price *
                                              (product.discountPercentage /
                                                  100))
                                        : 0.0,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.title} añadido al carrito',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.azulSistemas,
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
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Mantenemos Inicio resaltado
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
