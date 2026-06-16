import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/floating_chat_button.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _policies = [
    {
      'label': 'Cancelar pedido',
      'answer':
          'Puedes cancelar tu pedido dentro de las primeras 2 horas después de realizarlo. Pasado ese tiempo, si el pedido ya está en preparación no será posible cancelarlo.',
      'note': 'Para cancelar, ve a "Mis pedidos" y selecciona la opción cancelar en el pedido correspondiente.',
    },
    {
      'label': 'Devolver pedido',
      'answer':
          'Si recibes un producto defectuoso, incorrecto o en mal estado, puedes iniciar una devolución dentro de los 15 días hábiles siguientes a la entrega. El producto debe estar en su empaque original, sin uso y con todos sus accesorios. Una vez aprobada la solicitud, procesaremos el reembolso a tu método de pago original en un plazo de 5 a 7 días hábiles.',
      'note': 'Recuerda que tienes un plazo de 15 días hábiles para realizar cualquier reclamo.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      floatingActionButton: FloatingChatButton(),
      appBar: TopNavigationBar(
        titleWidget: Text('atencin_al_cliente'.tr(),
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
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('estamos_aqu_para_ayudarte'.tr(),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 12),
            Text('encuentra_soluciones_rpidas_para_tus_ped'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).sombras,
                height: 1.4,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 32),

            // Gestión de pedidos
            GuideWrapper(
              id: 'support_policies',
              title: 'divulgación_progresiva'.tr(),
              description: 'Utilizar un diseño de acordeón para las políticas extensas evita la sobrecarga visual. El usuario solo lee lo que necesita cuando lo necesita.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('gestin_de_pedidos'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('realiza_cambios_inmediatos_en_tus_compra'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Items expandibles
                  ..._policies.asMap().entries.map((entry) {
                    final i = entry.key;
                    final policy = entry.value;
                    final isExpanded = _expandedIndex == i;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _buildPolicyItem(theme, i, policy, isExpanded),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Canales de comunicación
            GuideWrapper(
              id: 'support_channels',
              title: 'confianza_y_accesibilidad'.tr(),
              description: 'Mostrar canales de contacto directos (WhatsApp y Llamada) con tiempos de respuesta o disponibilidad (ej: 8am - 5pm) reduce la ansiedad del usuario y genera confianza en la plataforma.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('canales_de_comunicacin'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),

                  // WhatsApp
                  _buildCommunicationCard(
                    context,
                    icon: Icons.chat,
                    iconColor: Color(0xFF25D366),
                    title: 'chat_vía_whatsapp'.tr(),
                    subtitle: 'respuesta_inmediata'.tr(),
                    onTap: () async {
                      final Uri url = Uri.parse('https://wa.me/584129141131');
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          CustomNotification.show(context, message: 'no_se_pudo_abrir_whatsapp'.tr(), type: NotificationType.info);
                        }
                      }
                    },
                  ),
                  SizedBox(height: 12),

                  // Llamar
                  _buildCommunicationCard(
                    context,
                    icon: Icons.phone,
                    iconColor: AppColors.of(context).sombras,
                    title: 'llamar'.tr(),
                    subtitle: 'lunes_a_viernes_8am_5pm'.tr(),
                    onTap: () async {
                      final Uri url = Uri.parse('tel:+584129141131');
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          CustomNotification.show(context, message: 'no_se_pudo_abrir_la'.tr(), type: NotificationType.info);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            GuideWrapper(
              id: 'support_faq',
              title: 'autoservicio_proactivo'.tr(),
              description: 'Destacar visualmente las Preguntas Frecuentes empodera a los usuarios a encontrar respuestas por sí mismos y disminuye drásticamente el volumen de tickets de soporte.',
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.of(context).azulSistemas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Text('sigues_con_dudas'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('consulta_nuestra_seccin_de_preguntas_fre'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.push('/faq'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.help_outline, color: AppColors.of(context).azulSistemas, size: 18),
                          SizedBox(width: 8),
                          Text('preguntas_frecuentes'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.of(context).azulSistemas,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }

  Widget _buildPolicyItem(ThemeData theme, int index, Map<String, String> policy, bool isExpanded) {
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).fondoTarjetas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded
                ? AppColors.of(context).azulSistemas.withValues(alpha: 0.6)
                : AppColors.of(context).sombras.withValues(alpha: 0.1),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    policy['label']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).naranjaUnimet, size: 22),
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 16),
              Text(
                policy['answer']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).sombras,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (policy['note'] != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).azulSistemas.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.of(context).azulSistemas, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          policy['note']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.of(context).azulSistemas,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).fondoTarjetas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 36),
            SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).sombras,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
