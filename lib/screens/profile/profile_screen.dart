import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() { _isUploadingImage = true; });
      try {
        final bytes = await pickedFile.readAsBytes();
        await ref.read(authRepositoryProvider).updateProfileImage(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('foto_actualizada_exitosamente'.tr())));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir foto: $e')));
        }
      } finally {
        if (mounted) {
          setState(() { _isUploadingImage = false; });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() { _isSaving = true; });
    try {
      await ref.read(authRepositoryProvider).updateProfileData(
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
      if (mounted) {
        setState(() { _isEditing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('perfil_guardado_con_éxito'.tr()),
            backgroundColor: AppColors.exito,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
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
              title: Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ref.read(authRepositoryProvider).sendPasswordReset();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('correo_de_recuperación_enviado'.tr())));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.naranjaUnimet)),
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancelar', style: TextStyle(color: AppColors.sombras)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranjaUnimet, foregroundColor: Colors.white),
                  onPressed: isLoading ? null : () async {
                    if (currentController.text.isEmpty || newController.text.isEmpty) return;
                    setStateDialog(() { isLoading = true; });
                    try {
                      await ref.read(authRepositoryProvider).changePassword(currentController.text, newController.text);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('contraseña_cambiada_con_éxito'.tr())));
                      }
                    } catch (e) {
                      setStateDialog(() { isLoading = false; });
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
                  child: isLoading 
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('cambiar'.tr()),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Factor de doble autenticación (2FA)', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'La integración real de 2FA (Google Authenticator / SMS) requiere habilitar Identity Platform en Firebase y configuración adicional en la consola de Google Cloud, lo que puede incurrir en costos de facturación.\n\n'
          'En un flujo real, aquí el usuario escanearía un código QR y verificaría su token TOTP para habilitarlo.',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Entendido', style: TextStyle(color: AppColors.naranjaUnimet)),
          )
        ],
      )
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

    final displayName = userData?['displayName'] ?? user?.displayName ?? 'Usuario';
    final email = user?.email ?? 'Sin correo';
    final photoUrl = userData?['photoUrl']?.isNotEmpty == true ? userData!['photoUrl'] : user?.photoURL;
    final phoneNumber = userData?['phoneNumber'] ?? user?.phoneNumber ?? '';

    // Initialize controllers once data is loaded
    if (!_controllersInitialized && (userData != null || user != null)) {
      _nameController.text = displayName;
      _phoneController.text = phoneNumber;
      _controllersInitialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Información personal',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
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
              title: 'personalización'.tr(),
              description: 'Permitir subir una foto de perfil refuerza la identidad y compromiso del usuario (engagement), al mismo tiempo que proporciona un feedback visual inmediato de su cuenta.',
              child: Center(
                child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.naranjaUnimet, width: 4),
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
                          ? Center(child: CircularProgressIndicator(color: AppColors.naranjaUnimet))
                          : photoUrl != null
                              ? Image.network(photoUrl, fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.fondoTarjetas,
                                  child: Icon(Icons.person, size: 60, color: AppColors.sombras),
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
                          color: AppColors.textoPrincipal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: AppColors.naranjaUnimet, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 24),
            
            // Nombre y Fecha
            Text(
              displayName,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.textoPrincipal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Miembro desde $memberSince',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.sombras,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 40),

            // Formulario
            GuideWrapper(
              title: 'prevención_de_errores_y_control'.tr(),
              description: 'Hacer que los datos obligatorios (como el teléfono) sean editables directamente aquí otorga flexibilidad al usuario y previene abandonos del carrito por falta de información vital.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Text('Datos Personales', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() { _isEditing = !_isEditing; }),
                  child: Text(_isEditing ? 'Cancelar' : 'Editar', style: TextStyle(color: AppColors.naranjaUnimet)),
                )
              ],
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'nombre_completo'.tr(),
              placeholder: 'Tu nombre',
              controller: _nameController,
              fillColor: _isEditing ? AppColors.blanco : AppColors.fondoTarjetas,
              enabled: _isEditing,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'correo_electrónico'.tr(),
              placeholder: email,
              fillColor: AppColors.fondoTarjetas,
              enabled: false,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'número_telefónico'.tr(),
              placeholder: 'Añadir número (obligatorio para comprar)',
              controller: _phoneController,
              fillColor: _isEditing ? AppColors.blanco : AppColors.fondoTarjetas,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            
            if (_isEditing) ...[
              SizedBox(height: 24),
              _isSaving
                  ? CircularProgressIndicator(color: AppColors.naranjaUnimet)
                  : SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Guardar cambios',
                        color: ButtonColor.naranja,
                        onPressed: _saveProfile,
                      ),
                    )
            ],
                ],
              ),
            ),

            SizedBox(height: 40),

            // Seguridad de la cuenta
            GuideWrapper(
              title: 'confianza_y_autonomía'.tr(),
              description: 'Centralizar los ajustes de seguridad transmite profesionalismo al usuario. Darle la libertad de gestionar su contraseña o ver opciones como el 2FA mejora drásticamente la percepción de seguridad del sistema.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Seguridad de la cuenta',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoPrincipal,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Divider(color: AppColors.sombras, thickness: 0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.fondoTarjetas,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSecurityOption(
                          context, 
                          'Cambiar contraseña', 
                          onTap: _showChangePasswordDialog,
                        ),
                        SizedBox(height: 12),
                        _buildSecurityOption(
                          context, 
                          'Factor de doble autenticación', 
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

  Widget _buildSecurityOption(BuildContext context, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blanco,
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
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textoPrincipal,
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.naranjaUnimet),
          ],
        ),
      ),
    );
  }
}
