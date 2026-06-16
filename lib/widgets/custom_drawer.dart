import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/guide_wrapper.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final firebaseUser = ref.watch(authStateProvider).value;
    final userData = ref.watch(userDataProvider).value;
    
    final photoUrl = userData?['photoUrl']?.isNotEmpty == true
        ? userData!['photoUrl']
        : firebaseUser?.photoURL;
    
    // Obtener la ruta actual dinámicamente de GoRouter
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: AppColors.of(context).blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 32),
            GuideWrapper(
              id: 'drawer_perfil',
              title: 'Perfil',
              description: 'Desde aquí puedes acceder a tu configuración personal y editar los datos de tu cuenta.',
              child: Column(
                children: [
                  _buildAvatar(context, photoUrl),
                  SizedBox(height: 16),
                  Text(
                    userData?['displayName']?.isNotEmpty == true
                        ? userData!['displayName']
                        : firebaseUser?.displayName ?? 'Usuario',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: AppColors.of(context).textoPrincipal,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    firebaseUser?.email ?? 'usuario@correo.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                    ),
                  ),
                  SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final editProfileColor = theme.brightness == Brightness.dark 
                          ? AppColors.of(context).naranjaUnimet 
                          : AppColors.of(context).azulSistemas;
                      return OutlinedButton.icon(
                    onPressed: () {
                      context.pop();
                      context.push('/profile');
                    },
                    icon: Icon(Icons.edit_outlined, size: 16, color: editProfileColor),
                    label: Text('editar_perfil'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: editProfileColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: editProfileColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                minimumSize: Size(0, 32),
              ),
            );
            }
          ),
          ],
        ),
      ),
      SizedBox(height: 16),
            
            Padding(
              padding: EdgeInsets.only(left: 24.0, right: 36.0),
              child: GuideWrapper(
                id: 'drawer_options',
                title: 'Navegación Centralizada',
                description: 'Un menú lateral estructurado (Hamburguesa) facilita el acceso a secciones secundarias sin saturar la barra de navegación inferior, reduciendo la carga cognitiva.',
                alignment: Alignment.centerRight,
                child: Divider(
                  color: AppColors.of(context).verdeSaman,
                  thickness: 1,
                ),
              ),
            ),

            // Opciones del menú (Scrollable)
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                  _buildDrawerItem(context, Icons.home, 'inicio'.tr(), '/home', currentRoute == '/home'),
                  _buildDrawerItem(context, Icons.history, 'historial_de_compras'.tr(), '/history', currentRoute == '/history'),
                  _buildDrawerItem(context, Icons.location_on, 'mis_direcciones'.tr(), '/addresses', currentRoute == '/addresses'),
                  _buildDrawerItem(context, Icons.attach_money, 'mis_mtodos_de_pago'.tr(), '/payment_methods', currentRoute == '/payment_methods'),
                  _buildDrawerItem(context, Icons.favorite, 'lista_de_deseos'.tr(), '/wishlist', currentRoute == '/wishlist'),
                  _buildDrawerItem(context, Icons.shopping_cart, 'carrito_de_compra'.tr(), '/cart', currentRoute == '/cart'),
                  
                  SizedBox(height: 8),
                  _buildGreenDivider(context),
                  SizedBox(height: 8),

                  _buildDrawerItem(context, Icons.help, 'preguntas_frecuentes'.tr(), '/faq', currentRoute == '/faq'),
                  _buildDrawerItem(context, Icons.settings, 'accesibilidad_y_personalizacion'.tr(), '/accessibility', currentRoute == '/accessibility'),
                  
                  SizedBox(height: 8),
                  _buildGreenDivider(context),
                  SizedBox(height: 16),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: CustomButton(
                      text: 'cerrar_sesin'.tr(),
                      color: ButtonColor.naranja,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(color: AppColors.of(context).naranjaUnimet),
                          ),
                        );
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Cierra el dialog
                          context.pop(); // Cierra el drawer
                          context.go('/');
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text('version_v100'.tr(),
                      style: TextStyle(
                        color: AppColors.of(context).sombras,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text('© 2026 Creado por Norangel Marín',
                      style: TextStyle(
                        color: AppColors.of(context).sombras,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? photoUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.of(context).naranjaUnimet, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // ligeramente menor para no superponer el borde
        child: photoUrl != null
            ? (photoUrl.startsWith('data:image')
                ? Image.memory(
                    base64Decode(photoUrl.split(',').last),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                  ))
            : Icon(Icons.person, size: 80, color: AppColors.of(context).sombras), // Placeholder de foto
      ),
    );
  }

  Widget _buildGreenDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Divider(
        color: AppColors.of(context).verdeSaman,
        thickness: 1,
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.of(context).naranjaUnimet.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: Icon(
          icon, 
          color: isActive ? AppColors.of(context).naranjaUnimet : AppColors.of(context).sombras,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.of(context).naranjaUnimet : Color(0xFF666666), // sombras
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: () {
          context.pop(); // Cierra el drawer
          // Si ya estamos en la ruta, no hacemos push
          if (!isActive) {
            if (route == '/home') {
              context.go('/home');
            } else {
              context.push(route);
            }
          }
        },
      ),
    );
  }
}
