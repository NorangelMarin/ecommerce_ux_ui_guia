import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final firebaseUser = ref.watch(authStateProvider).value;
    
    // Obtener la ruta actual dinámicamente de GoRouter
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: AppColors.blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Cabecera (Avatar y Perfil)
            SizedBox(height: 32),
            _buildAvatar(firebaseUser?.photoURL),
            SizedBox(height: 16),
            Text(
              firebaseUser?.displayName ?? 'Usuario',
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.textoPrincipal,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              firebaseUser?.email ?? 'usuario@correo.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.sombras,
              ),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                context.pop();
                context.push('/profile');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EDITAR PERFIL',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.azulSistemas,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.azulSistemas),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            _buildGreenDivider(),

            // Opciones del menú (Scrollable)
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(context, Icons.home, 'Inicio', '/home', currentRoute == '/home'),
                  _buildDrawerItem(context, Icons.history, 'Historial de compras', '/history', currentRoute == '/history'),
                  _buildDrawerItem(context, Icons.location_on, 'Mis direcciones', '/addresses', currentRoute == '/addresses'),
                  _buildDrawerItem(context, Icons.attach_money, 'Mis métodos de pago', '/payment_methods', currentRoute == '/payment_methods'),
                  _buildDrawerItem(context, Icons.favorite, 'Lista de deseos', '/wishlist', currentRoute == '/wishlist'),
                  _buildDrawerItem(context, Icons.shopping_cart, 'Carrito de compra', '/cart', currentRoute == '/cart'),
                  
                  SizedBox(height: 8),
                  _buildGreenDivider(),
                  SizedBox(height: 8),

                  _buildDrawerItem(context, Icons.help, 'Preguntas frecuentes', '/faq', currentRoute == '/faq'),
                  _buildDrawerItem(context, Icons.settings, 'Accesibilidad y personalización', '/accessibility', currentRoute == '/accessibility'),
                  
                  SizedBox(height: 8),
                  _buildGreenDivider(),
                  SizedBox(height: 16),
                  
                  // Footer: Botón Cerrar Sesión y Versión
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: CustomButton(
                      text: 'Cerrar sesión',
                      color: ButtonColor.naranja,
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          context.pop();
                          context.go('/');
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'VERSION V.1.0.0',
                      style: TextStyle(
                        color: AppColors.sombras,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Widget _buildAvatar(String? photoUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.fondoTarjetas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.naranjaUnimet, width: 4),
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
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
              )
            : Icon(Icons.person, size: 80, color: AppColors.sombras), // Placeholder de foto
      ),
    );
  }

  Widget _buildGreenDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Divider(
        color: AppColors.verdeSaman,
        thickness: 1,
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.naranjaUnimet.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: Icon(
          icon, 
          color: isActive ? AppColors.naranjaUnimet : AppColors.sombras,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.naranjaUnimet : Color(0xFF666666), // sombras
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: () {
          context.pop(); // Cierra el drawer
          // Si ya estamos en la ruta, no hacemos push
          if (!isActive) {
            context.push(route);
          }
        },
      ),
    );
  }
}
