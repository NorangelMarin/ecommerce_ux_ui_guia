import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/checkout_stepper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

/// Contenedor con los datos de dirección seleccionados en el flujo de checkout.
class CheckoutAddressData {
  final String? addressId; // ID si es una dirección guardada
  final Address? newAddress; // Objeto si es nueva (no guardada)
  CheckoutAddressData({this.addressId, this.newAddress});
}

class ShippingScreen extends ConsumerStatefulWidget {
  const ShippingScreen({super.key});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  String? _selectedAddress;
  bool _saveAddress = false;
  bool _isSaving = false;
  bool _isGettingLocation = false;

  final _estadoController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _municipioController = TextEditingController();
  final _urbanizacionController = TextEditingController();
  final _aliasController = TextEditingController();

  @override
  void dispose() {
    _estadoController.dispose();
    _ciudadController.dispose();
    _municipioController.dispose();
    _urbanizacionController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Los permisos de ubicación están denegados permanentemente.',
        );
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _estadoController.text = place.administrativeArea ?? '';
          _ciudadController.text =
              place.locality ?? place.subAdministrativeArea ?? '';
          _municipioController.text = place.subLocality ?? place.locality ?? '';
          _urbanizacionController.text =
              '${place.street ?? ''} ${place.thoroughfare ?? ''}'.trim();
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        String errorMessage = 'Error de sistema al obtener ubicación.';
        if (e.code == 'PERMISSION_DENIED') {
          errorMessage = 'Permiso de ubicación denegado por el sistema.';
        } else if (e.code == 'LOCATION_SERVICES_DISABLED') {
          errorMessage = 'El GPS está desactivado en tu dispositivo.';
        }

        CustomNotification.show(context, message: errorMessage, type: NotificationType.error);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'No pudimos obtener tu ubicación.';
        if (e is Exception) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        CustomNotification.show(context, message: errorMessage, type: NotificationType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(userAddressesProvider);
    final addresses = addressesAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'elige_dnde_quieres_recibir_tu_pedido'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.of(context).blanco,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.of(context).sombras.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutStepper(currentStep: 1),
                  SizedBox(height: 32),

                  Text(
                    'direccin_de_envo'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'completa_los_datos_para_coordinar_el_env'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Componente desplegable
                  CustomDropdownField<String>(
                    label: 'dirección_de_envío'.tr(),
                    placeholder: 'seleccione_una_dirección'.tr(),
                    value:
                        _selectedAddress ??
                        (addresses.isEmpty ? 'nueva' : null),
                    items: [
                      ...addresses.map(
                        (addr) => DropdownMenuItem(
                          value: addr.id,
                          child: Text(
                            '${addr.label} - ${addr.ciudad}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'nueva',
                        child: Text('nueva_direccion'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                        if (value != 'nueva') _saveAddress = false;
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  if ((_selectedAddress ??
                          (addresses.isEmpty ? 'nueva' : null)) ==
                      'nueva') ...[
                    GuideWrapper(
                      title: 'automatización_y_prevención_de_errores'.tr(),
                      description:
                          'Permitir el uso del GPS previene errores tipográficos en la dirección y acelera el llenado del formulario, lo que reduce la fricción y aumenta la conversión.',
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: _isGettingLocation
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.my_location, size: 18),
                          label: Text('usar_mi_ubicación_actual'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.of(context).naranjaUnimet,
                            side: BorderSide(color: AppColors.of(context).naranjaUnimet),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isGettingLocation
                              ? null
                              : _getCurrentLocation,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'estado'.tr(),
                      placeholder: 'Ej. Distrito Capital',
                      controller: _estadoController,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'ciudad'.tr(),
                      placeholder: 'Ej. Caracas',
                      controller: _ciudadController,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'municipio'.tr(),
                      placeholder: 'Ej. Chacao',
                      controller: _municipioController,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'ubicacion_detallada'.tr(),
                      placeholder: 'Ej. La Castellana, Edif...',
                      controller: _urbanizacionController,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Theme(
                            data: theme.copyWith(
                              checkboxTheme: theme.checkboxTheme.copyWith(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            child: Checkbox(
                              value: _saveAddress,
                              onChanged: (val) =>
                                  setState(() => _saveAddress = val ?? false),
                              activeColor: AppColors.of(context).azulSistemas,
                              checkColor: Colors.white,
                              side: BorderSide.none,
                              fillColor: WidgetStateProperty.all(
                                AppColors.of(context).azulSistemas,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _saveAddress = !_saveAddress),
                          child: Text(
                            'guardar_en_mis_direcciones'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.of(context).sombras,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_saveAddress) ...[
                      SizedBox(height: 24),
                      CustomTextField(
                        label: 'alias_ej_trabajo_casa'.tr(),
                        placeholder: 'Ej. Casa, Trabajo, Novia',
                        controller: _aliasController,
                      ),
                    ],
                  ],

                  SizedBox(height: 48),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButton(
                      text: _isSaving
                          ? 'guardando'.tr()
                          : 'ir_a_metodo_de_pago'.tr(),
                      color: ButtonColor.naranja,
                      icon: Icons.chevron_right,
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final currentSelection =
                                  _selectedAddress ??
                                  (addresses.isEmpty ? 'nueva' : null);

                              if (currentSelection == null) {
                                CustomNotification.show(context, message: 'por_favor_selecciona_una_direccin'.tr(), type: NotificationType.info);
                                return;
                              }

                              if (currentSelection == 'nueva') {
                                // --- Nueva dirección: puede guardarla o no ---
                                if (_estadoController.text.trim().isEmpty ||
                                    _ciudadController.text.trim().isEmpty ||
                                    _municipioController.text.trim().isEmpty ||
                                    _urbanizacionController.text
                                        .trim()
                                        .isEmpty) {
                                  CustomNotification.show(context, message: 'por_favor_completa_todos_los_campos_de_l'
                                            .tr(), type: NotificationType.error);
                                  return;
                                }

                                if (_saveAddress &&
                                    _aliasController.text.trim().isEmpty) {
                                  CustomNotification.show(context, message: 'por_favor_ingresa_un_alias_para_guardar'
                                            .tr(), type: NotificationType.error);
                                  return;
                                }

                                // Construir objeto de dirección temporal
                                final tempAddress = Address(
                                  id: '',
                                  label: _aliasController.text.trim().isNotEmpty
                                      ? _aliasController.text.trim()
                                      : 'nueva_direccion'.tr(),
                                  labelColor: 'orange',
                                  estado: _estadoController.text.trim(),
                                  ciudad: _ciudadController.text.trim(),
                                  municipio: _municipioController.text.trim(),
                                  urbanizacion: _urbanizacionController.text
                                      .trim(),
                                  isDefault: true,
                                );

                                if (_saveAddress) {
                                  setState(() => _isSaving = true);
                                  final user = ref
                                      .read(authStateProvider)
                                      .value;
                                  if (user != null) {
                                    final savedId = await ref
                                        .read(addressRepositoryProvider)
                                        .addAddress(user.uid, tempAddress);
                                    if (mounted) {
                                      setState(() => _isSaving = false);
                                    }
                                    if (mounted) {
                                      context.push(
                                        '/payment_method',
                                        extra: CheckoutAddressData(
                                          addressId: savedId,
                                        ),
                                      );
                                    }
                                  }
                                  return;
                                }

                                // Nueva sin guardar: la pasamos como objeto temporal
                                if (mounted) {
                                  context.push(
                                    '/payment_method',
                                    extra: CheckoutAddressData(
                                      newAddress: tempAddress,
                                    ),
                                  );
                                }
                                return;
                              }

                              // Dirección guardada seleccionada
                              if (mounted) {
                                context.push(
                                  '/payment_method',
                                  extra: CheckoutAddressData(
                                    addressId: currentSelection,
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
