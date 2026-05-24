import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupportBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GuideWrapper(
      title: 'botón_flotante_de_soporte'.tr(),
      description: 'Ofrecer acceso rápido a soporte genera confianza, especialmente importante en compras online en Venezuela. Su ubicación inferior derecha (pulgar) facilita el acceso.',
      alignment: Alignment.topLeft,
      child: GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _openSupportSheet(context);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.naranjaUnimet,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.naranjaUnimet.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.chat_bubble,
            color: AppColors.blanco,
            size: 24,
          ),
        ),
      ),
    ),
    );
  }
}

class _SupportBottomSheet extends StatelessWidget {
  const _SupportBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.sombras.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.naranjaUnimet.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: AppColors.naranjaUnimet,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Necesitas ayuda?',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textoPrincipal,
                      ),
                    ),
                    Text(
                      'Elige un canal de contacto',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.sombras,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Divider(height: 1, color: Color(0xFFEEEEEE)),
          // WhatsApp
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chat, color: Color(0xFF25D366), size: 22),
            ),
            title: Text(
              'Chat vía Whatsapp',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textoPrincipal,
              ),
            ),
            subtitle: Text(
              'Respuesta inmediata',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.sombras,
                fontSize: 11,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.sombras,
              size: 18,
            ),
            onTap: () async {
              Navigator.of(context).pop();
              final Uri url = Uri.parse('https://wa.me/584129141131');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('no_se_pudo_abrir_whatsapp'.tr())),
                  );
                }
              }
            },
          ),
          Divider(height: 1, indent: 72, color: Color(0xFFEEEEEE)),
          // Llamar
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.azulSistemas.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.phone,
                color: AppColors.azulSistemas,
                size: 22,
              ),
            ),
            title: Text(
              'Llamar',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textoPrincipal,
              ),
            ),
            subtitle: Text(
              'Lunes a viernes, 8am - 5pm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.sombras,
                fontSize: 11,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.sombras,
              size: 18,
            ),
            onTap: () async {
              Navigator.of(context).pop();
              final Uri url = Uri.parse('tel:+584129141131');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No se pudo abrir la aplicación de llamadas',
                      ),
                    ),
                  );
                }
              }
            },
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
