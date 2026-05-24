import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(userAddressesProvider);

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Mis direcciones',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tus ubicaciones guardadas',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.textoPrincipal,
              ),
            ),
            SizedBox(height: 24),

            // Tarjetas de direcciones
            addressesAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.naranjaUnimet)),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (addresses) {
                if (addresses.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text('No tienes direcciones guardadas.', style: TextStyle(color: AppColors.sombras)),
                  );
                }
                return Column(
                  children: addresses.map((addr) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildAddressCard(context, ref, addr),
                  )).toList(),
                );
              },
            ),

            // Botón agregar nueva dirección
            _buildAddNewCard(context, ref),

            SizedBox(height: 16),

            // Tarjeta de ubicación GPS
            _buildGpsCard(context, ref),

            SizedBox(height: 16),
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

  Widget _buildAddNewCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GuideWrapper(
      title: 'asequibilidad_visual_affordance'.tr(),
      description: 'El uso de un diseño diferenciado (borde resaltado) y un icono "+" claro sirve como un "call to action" evidente que invita al usuario a interactuar intuitivamente.',
      child: GestureDetector(
        onTap: () {
          context.push('/add_address');
        },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.naranjaUnimet.withValues(alpha: 0.5),
            width: 1.5,
            // Simulamos línea punteada con color y grosor
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.naranjaUnimet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.naranjaUnimet, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              'Agregar nueva dirección',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.naranjaUnimet,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildAddressCard(BuildContext context, WidgetRef ref, Address addr) {
    final theme = Theme.of(context);
    final badgeColor = _getBadgeColor(addr.labelColor);

    return GuideWrapper(
      title: 'reconocimiento_vs_recuerdo'.tr(),
      description: 'Asignar etiquetas cortas ("Casa", "Oficina") con colores ayuda al usuario a reconocer rápidamente sus ubicaciones guardadas sin tener que leer y recordar toda la dirección exacta, reduciendo la carga cognitiva.',
      child: Container(
        padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + icono lápiz
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    addr.label,
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: AppColors.azulSistemas, size: 20),
                    onPressed: () {
                      context.push('/add_address', extra: addr);
                    },
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () async {
                      final user = ref.read(authStateProvider).value;
                      if (user != null) {
                        await ref.read(addressRepositoryProvider).deleteAddress(user.uid, addr.id);
                      }
                    }, // Acción eliminar
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Tipo de dirección
          Text(
            'Dirección de envío',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textoPrincipal,
            ),
          ),
          SizedBox(height: 10),

          // Datos de dirección
          _buildAddressRow(theme, 'Estado:', addr.estado),
          _buildAddressRow(theme, 'Ciudad:', addr.ciudad),
          _buildAddressRow(theme, 'Municipio:', addr.municipio),
          _buildAddressRow(theme, 'Ubicación detallada:', addr.urbanizacion),
        ],
      ),
    ));
  }

  Widget _buildAddressRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textoPrincipal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: AppColors.sombras,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentAddressText = 'Ubicación detectada por GPS';

    return GuideWrapper(
      title: 'prevención_de_errores_y_eficiencia'.tr(),
      description: 'Aprovechar el hardware del dispositivo (GPS) para geolocalizar al usuario previene errores tipográficos comunes al escribir direcciones manualmente y agiliza considerablemente el ingreso de datos.',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación Actual',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textoPrincipal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agiliza el proceso de selección de ubicación guardando tu ubicación ahora:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.sombras,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            
            // Texto plano de la dirección
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.naranjaUnimet, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentAddressText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoPrincipal,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Botón
            CustomButton(
              text: 'Fijar ubicación',
              color: ButtonColor.naranja,
              onPressed: () {
                _handleGpsLocation(context, ref);
              },
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _handleGpsLocation(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: CircularProgressIndicator(color: AppColors.naranjaUnimet)),
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos denegados');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos permanentemente denegados');
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar loading

      String addressText = 'Ubicación obtenida';
      String estado = '';
      String ciudad = '';
      String municipio = '';
      String urbanizacion = '';

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        urbanizacion = p.subLocality ?? p.street ?? '';
        municipio = p.locality ?? '';
        ciudad = p.subAdministrativeArea ?? p.administrativeArea ?? '';
        estado = p.administrativeArea ?? '';
        addressText = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
      }

      _showSaveAddressDialog(context, ref, addressText, estado, ciudad, municipio, urbanizacion);

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showSaveAddressDialog(
    BuildContext context, 
    WidgetRef ref, 
    String fullAddress, 
    String estado, 
    String ciudad, 
    String municipio, 
    String urbanizacion,
  ) {
    final aliasController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('guardar_ubicación'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dirección:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.sombras),
              ),
              SizedBox(height: 4),
              Text(
                fullAddress,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              TextField(
                controller: aliasController,
                decoration: InputDecoration(
                  labelText: 'Alias (Ej. Casa, Oficina)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: AppColors.sombras)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranjaUnimet,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final alias = aliasController.text.trim();
                if (alias.isEmpty) return;

                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final newAddress = Address(
                    id: '',
                    label: alias,
                    labelColor: 'orange',
                    estado: estado.isNotEmpty ? estado : 'No especificado',
                    ciudad: ciudad.isNotEmpty ? ciudad : 'No especificado',
                    municipio: municipio.isNotEmpty ? municipio : 'No especificado',
                    urbanizacion: urbanizacion.isNotEmpty ? urbanizacion : 'No especificado',
                  );
                  await ref.read(addressRepositoryProvider).addAddress(user.uid, newAddress);
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('dirección_guardada_correctamente'.tr())),
                  );
                }
              },
              child: Text('guardar'.tr()),
            ),
          ],
        );
      },
    );
  }

  Color _getBadgeColor(String colorKey) {
    switch (colorKey) {
      case 'orange':
        return AppColors.naranjaUnimet;
      case 'blue':
        return AppColors.azulSistemas;
      case 'green':
        return AppColors.verdeSaman;
      default:
        return AppColors.sombras;
    }
  }
}
