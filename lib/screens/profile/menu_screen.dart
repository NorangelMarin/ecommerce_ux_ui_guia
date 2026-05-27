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
          Text('juan_prez'.tr(), textAlign: TextAlign.center, style: theme.textTheme.displayMedium),
          SizedBox(height: 32),
          Text('mi_cuenta'.tr(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 8),
          _buildMenuItem(context, Icons.person_outline, 'perfil'.tr(), '/profile'),
          _buildMenuItem(context, Icons.history, 'historial_de_compras'.tr(), '/history'),
          _buildMenuItem(context, Icons.location_on_outlined, 'mis_direcciones'.tr(), '/addresses'),
          _buildMenuItem(context, Icons.payment, 'mis_mtodos_de_pago'.tr(), '/payment_methods'),
          SizedBox(height: 24),
          Text('configuracin'.tr(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 8),
          _buildMenuItem(context, Icons.support_agent, 'soporte'.tr(), '/support'),
          _buildMenuItem(context, Icons.help_outline, 'preguntas_frecuentes'.tr(), '/faq'),
          _buildMenuItem(context, Icons.accessibility, 'accesibilidad'.tr(), '/accessibility'),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('cerrar_sesin'.tr(), style: TextStyle(color: Colors.red)),
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
