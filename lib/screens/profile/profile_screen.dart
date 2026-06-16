import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedPrefix = '0414';
  final List<String> _phonePrefixes = ['0412', '0414', '0416', '0424', '0426', '0212'];

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20, // Reduced quality to keep Base64 string small
    );

    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true;
      });
      try {
        final bytes = await pickedFile.readAsBytes();
        await ref.read(authRepositoryProvider).updateProfileImage(bytes);
        if (mounted) {
          CustomNotification.show(context, message: 'foto_actualizada_exitosamente'.tr(), type: NotificationType.info);
        }
      } catch (e) {
        if (mounted) {
          CustomNotification.show(context, message: 'error_al_subir_foto'.tr(args: [e.toString()]), type: NotificationType.error);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final phoneDigits = _phoneController.text.trim();
    if (phoneDigits.length != 7) {
      CustomNotification.show(context, message: 'el_nmero_de_telfono_debe_tener_7'.tr(), type: NotificationType.info);
      return;
    }
    
    final fullPhone = '$_selectedPrefix$phoneDigits';

    setState(() {
      _isSaving = true;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfileData(
            _nameController.text.trim(),
            fullPhone,
          );
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        CustomNotification.show(context, message: 'perfil_guardado_con_éxito'.tr(), type: NotificationType.success);
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.show(context, message: 'error_general'.tr(args: [e.toString()]), type: NotificationType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'cambiar_contrasea'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'contrasea_actual'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'nueva_contrasea'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ref
                              .read(authRepositoryProvider)
                              .sendPasswordReset();
                          if (mounted) {
                            CustomNotification.show(context, message: 'correo_de_recuperación_enviado'.tr(), type: NotificationType.info);
                          }
                        } catch (e) {
                          if (mounted) {
                            CustomNotification.show(context, message: 'error_general'.tr(args: [e.toString()]), type: NotificationType.error);
                          }
                        }
                      },
                      child: Text(
                        'olvidaste_tu_contrasea'.tr(),
                        style: TextStyle(color: AppColors.of(context).naranjaUnimet),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'cancelar'.tr(),
                    style: TextStyle(color: AppColors.of(context).sombras),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).naranjaUnimet,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (currentController.text.isEmpty ||
                              newController.text.isEmpty)
                            return;
                          setStateDialog(() {
                            isLoading = true;
                          });
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .changePassword(
                                  currentController.text,
                                  newController.text,
                                );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              CustomNotification.show(context, message: 'contraseña_cambiada_con_éxito'.tr(), type: NotificationType.success);
                            }
                          } catch (e) {
                            setStateDialog(() {
                              isLoading = false;
                            });
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              );
CustomNotification.show(context, message: '$e', type: NotificationType.error);
                            }
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('cambiar'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'factor_de_doble_autenticacin_2fa'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'La integración real de 2FA (Google Authenticator / SMS) requiere habilitar Identity Platform en Firebase y configuración adicional en la consola de Google Cloud, lo que puede incurrir en costos de facturación.\n\n'
          'En un flujo real, aquí el usuario escanearía un código QR y verificaría su token TOTP para habilitarlo.',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'entendido'.tr(),
              style: TextStyle(color: AppColors.of(context).naranjaUnimet),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final userData = ref.watch(userDataProvider).value;

    final creationTime = user?.metadata.creationTime;
    final memberSince = creationTime != null
        ? '${creationTime.day.toString().padLeft(2, '0')}/${creationTime.month.toString().padLeft(2, '0')}/${creationTime.year}'
        : 'Desconocido';

    final displayName =
        userData?['displayName'] ?? user?.displayName ?? 'Usuario';
    final email = user?.email ?? 'Sin correo';
    final photoUrl = userData?['photoUrl']?.isNotEmpty == true
        ? userData!['photoUrl']
        : user?.photoURL;
    final phoneNumber = userData?['phoneNumber'] ?? user?.phoneNumber ?? '';

    // Initialize controllers once data is loaded
    if (!_controllersInitialized && (userData != null || user != null)) {
      _nameController.text = displayName;
      
      String phone = phoneNumber;
      phone = phone.replaceAll(RegExp(r'\D'), ''); // Remove all non-digits (like +, -, spaces)
      if (phone.startsWith('58')) {
        phone = '0${phone.substring(2)}'; // Convert 58414... to 0414...
      }
      
      if (phone.length >= 11) {
        String prefix = phone.substring(0, 4);
        if (_phonePrefixes.contains(prefix)) {
          _selectedPrefix = prefix;
          phone = phone.substring(4);
        }
      }
      _phoneController.text = phone;
      _controllersInitialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'informacin_personal'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Foto de Perfil
            GuideWrapper(
              id: 'profile_photo',
              title: 'personalización'.tr(),
              description:
                  'Permitir subir una foto de perfil refuerza la identidad y compromiso del usuario (engagement), al mismo tiempo que proporciona un feedback visual inmediato de su cuenta.',
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).blanco,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.of(context).naranjaUnimet,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _isUploadingImage
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.of(context).naranjaUnimet,
                                ),
                              )
                            : photoUrl != null
                            ? (photoUrl.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(photoUrl.split(',').last),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(photoUrl, fit: BoxFit.cover))
                            : Container(
                                color: AppColors.of(context).fondoTarjetas,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.of(context).sombras,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).textoPrincipal,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.of(context).naranjaUnimet,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Nombre y Fecha
            Text(
              displayName,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${'Miembro desde'.tr()} $memberSince',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).sombras,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 40),

            GuideWrapper(
              id: 'profile_editable_data',
              title: 'prevención_de_errores_y_control'.tr(),
              description:
                  'Hacer que los datos obligatorios (como el teléfono) sean editables directamente aquí otorga flexibilidad al usuario y previene abandonos del carrito por falta de información vital.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'datos_personales'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _isEditing = !_isEditing;
                        }),
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          size: 16,
                          color: AppColors.of(context).naranjaUnimet,
                        ),
                        label: Text(
                          _isEditing ? 'cancelar'.tr() : 'editar'.tr(),
                          style: TextStyle(
                            color: AppColors.of(context).naranjaUnimet,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.of(context).naranjaUnimet),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size(0, 36),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'nombre_completo'.tr(),
                    placeholder: 'Tu nombre',
                    controller: _nameController,
                    fillColor: _isEditing
                        ? AppColors.of(context).blanco
                        : AppColors.of(context).fondoTarjetas,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'correo_electrónico'.tr(),
                    placeholder: email,
                    fillColor: AppColors.of(context).fondoTarjetas,
                    enabled: false,
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildPrefixSelector(),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 7,
                        child: CustomTextField(
                          label: 'número_telefónico'.tr(),
                          placeholder: '1234567',
                          controller: _phoneController,
                          fillColor: _isEditing
                              ? AppColors.of(context).blanco
                              : AppColors.of(context).fondoTarjetas,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(7),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (_isEditing) ...[
                    SizedBox(height: 24),
                    _isSaving
                        ? CircularProgressIndicator(
                            color: AppColors.of(context).naranjaUnimet,
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'guardar_cambios'.tr(),
                              color: ButtonColor.naranja,
                              onPressed: _saveProfile,
                            ),
                          ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 40),

            // Seguridad de la cuenta
            GuideWrapper(
              id: 'profile_security',
              title: 'confianza_y_autonomía'.tr(),
              description:
                  'Centralizar los ajustes de seguridad transmite profesionalismo al usuario. Darle la libertad de gestionar su contraseña o ver opciones como el 2FA mejora drásticamente la percepción de seguridad del sistema.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'seguridad_de_la_cuenta'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.of(context).textoPrincipal,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Divider(
                          color: AppColors.of(context).sombras,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).fondoTarjetas,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSecurityOption(
                          context,
                          'cambiar_contrasea'.tr(),
                          onTap: _showChangePasswordDialog,
                        ),
                        SizedBox(height: 12),
                        _buildSecurityOption(
                          context,
                          'factor_de_doble_autenticacin_2fa'.tr(),
                          onTap: _show2FADialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48),
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

  Widget _buildSecurityOption(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.of(context).blanco,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.of(context).textoPrincipal,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.of(context).naranjaUnimet),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefixSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'código'.tr(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          height: 48, // Ajustar altura para igualar CustomTextField
          decoration: BoxDecoration(
            color: _isEditing ? AppColors.of(context).blanco : AppColors.of(context).fondoTarjetas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.of(context).sombras.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPrefix,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).sombras),
                onChanged: _isEditing
                    ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPrefix = newValue;
                          });
                        }
                      }
                    : null,
                items: _phonePrefixes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
