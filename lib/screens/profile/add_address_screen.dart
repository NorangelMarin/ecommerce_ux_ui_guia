import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import 'package:easy_localization/easy_localization.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final Address? addressToEdit;
  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  bool _isSaving = false;
  bool _isGettingLocation = false;

  final _estadoController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _municipioController = TextEditingController();
  final _urbanizacionController = TextEditingController();
  final _aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      final addr = widget.addressToEdit!;
      _estadoController.text = addr.estado;
      _ciudadController.text = addr.ciudad;
      _municipioController.text = addr.municipio;
      _urbanizacionController.text = addr.urbanizacion;
      _aliasController.text = addr.label;
    }
  }

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
        throw Exception('Los permisos de ubicación están denegados permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _estadoController.text = place.administrativeArea ?? '';
          _ciudadController.text = place.locality ?? place.subAdministrativeArea ?? '';
          _municipioController.text = place.subLocality ?? place.locality ?? '';
          _urbanizacionController.text = '${place.street ?? ''} ${place.thoroughfare ?? ''}'.trim();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error obteniendo ubicación: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    final estado = _estadoController.text.trim();
    final ciudad = _ciudadController.text.trim();
    final municipio = _municipioController.text.trim();
    final urbanizacion = _urbanizacionController.text.trim();
    final alias = _aliasController.text.trim();

    if (estado.isEmpty || ciudad.isEmpty || municipio.isEmpty || urbanizacion.isEmpty || alias.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('por_favor_completa_todos_los'.tr())),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
        final user = ref.read(authStateProvider).value;
        if (user != null) {
          if (widget.addressToEdit != null) {
            final updatedAddress = Address(
              id: widget.addressToEdit!.id,
              estado: estado,
              ciudad: ciudad,
              municipio: municipio,
              urbanizacion: urbanizacion,
              label: alias,
              labelColor: widget.addressToEdit!.labelColor,
              isDefault: widget.addressToEdit!.isDefault,
            );
            await ref.read(addressRepositoryProvider).updateAddress(user.uid, updatedAddress);
          } else {
            final newAddress = Address(
              id: '',
              estado: estado,
              ciudad: ciudad,
              municipio: municipio,
              urbanizacion: urbanizacion,
              label: alias,
              labelColor: 'orange', // Default color
            );
            await ref.read(addressRepositoryProvider).addAddress(user.uid, newAddress);
          }
          if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: TopNavigationBar(
        titleWidget: Text(
          widget.addressToEdit != null ? 'Editar dirección' : 'Agregar dirección',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
          ),
        ),
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => context.pop(),
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sombras.withValues(alpha: 0.05),
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
                  Text(
                    widget.addressToEdit != null ? 'Editar dirección' : 'Nueva dirección',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.addressToEdit != null 
                        ? 'Modifica los datos de tu ubicación.' 
                        : 'Completa los datos para guardar una nueva ubicación.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.sombras,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _isGettingLocation
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.my_location, size: 18),
                      label: Text('usar_mi_ubicación_actual'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.naranjaUnimet,
                        side: BorderSide(color: AppColors.naranjaUnimet),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
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
                    label: 'ubicación_detallada'.tr(),
                    placeholder: 'Ej. La Castellana, Edif...',
                    controller: _urbanizacionController,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'alias_ej_trabajo_casa'.tr(),
                    placeholder: 'Ej. Casa, Trabajo',
                    controller: _aliasController,
                  ),
                  
                  SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: _isSaving
                        ? Center(child: CircularProgressIndicator(color: AppColors.naranjaUnimet))
                        : CustomButton(
                            text: widget.addressToEdit != null ? 'Actualizar dirección' : 'Guardar dirección',
                            color: ButtonColor.naranja,
                            onPressed: _saveAddress,
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
