import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TopNavigationBar(
        title: 'mi_usuario'.tr(),
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => context.pop(),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          SizedBox(height: 16),
          Text('Juan Pérez', textAlign: TextAlign.center, style: theme.textTheme.displayMedium),
          SizedBox(height: 32),
          Text('MI CUENTA', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 8),
          _buildMenuItem(context, Icons.person_outline, 'Perfil', '/profile'),
          _buildMenuItem(context, Icons.history, 'Historial de compras', '/history'),
          _buildMenuItem(context, Icons.location_on_outlined, 'Mis direcciones', '/addresses'),
          _buildMenuItem(context, Icons.payment, 'Mis métodos de pago', '/payment_methods'),
          SizedBox(height: 24),
          Text('CONFIGURACIÓN', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 8),
          _buildMenuItem(context, Icons.support_agent, 'Soporte', '/support'),
          _buildMenuItem(context, Icons.help_outline, 'Preguntas frecuentes', '/faq'),
          _buildMenuItem(context, Icons.accessibility, 'Accesibilidad', '/accessibility'),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => context.go('/'),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
