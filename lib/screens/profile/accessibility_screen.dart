import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/accessibility_provider.dart';

class AccessibilityScreen extends ConsumerWidget {
  AccessibilityScreen({super.key});

  final List<String> _languages = [
    'Español',
    'English',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accessState = ref.watch(accessibilityProvider);
    final accessNotifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'accesibilidad_y_personalizacion'.tr(),
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
            Text(
              'disena_tu_experiencia_visual'.tr(),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'personaliza_el_entorno_de'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).sombras,
                height: 1.4,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 32),

            _buildCard(context, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields, color: AppColors.of(context).naranjaUnimet, size: 28),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'tamano_del_texto'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ajusta_la_escala_tipografica'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.of(context).naranjaUnimet,
                      thumbColor: AppColors.of(context).naranjaUnimet,
                      inactiveTrackColor: AppColors.of(context).sombras.withValues(alpha: 0.2),
                      overlayColor: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.1),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: accessState.textScale,
                      onChanged: (v) => accessNotifier.setTextScale(v),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('pequeno'.tr(), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.of(context).sombras, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Expanded(child: Text('grande'.tr(), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.of(context).sombras, fontSize: 11), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Modo de alto contraste
            _buildToggleCard(
              context,
              icon: Icons.contrast,
              title: 'modo_de_alto_contraste'.tr(),
              subtitle: 'mejora_la_legibilidad_de_los'.tr(),
              value: accessState.highContrast,
              onChanged: (v) => accessNotifier.setHighContrast(v),
            ),

            SizedBox(height: 16),

            // Búsqueda por voz
            _buildToggleCard(
              context,
              icon: Icons.record_voice_over,
              title: 'busqueda_por_voz'.tr(),
              subtitle: 'navega_usando_comandos_de_audio'.tr(),
              value: accessState.voiceSearch,
              onChanged: (v) => accessNotifier.setVoiceSearch(v),
            ),

            SizedBox(height: 16),

            // Modo nocturno
            _buildToggleCard(
              context,
              icon: Icons.dark_mode,
              title: 'modo_nocturno'.tr(),
              subtitle: 'reduce_la_fatiga_visual_en'.tr(),
              value: accessState.nightMode,
              onChanged: (v) => accessNotifier.setNightMode(v),
            ),

            SizedBox(height: 16),

            // Región e Idioma
            _buildCard(context, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language, color: AppColors.of(context).naranjaUnimet, size: 28),
                  SizedBox(height: 12),
                  Text(
                    'region_e_idioma'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'selecciona_el_idioma'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.of(context).sombras,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).blanco,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: accessState.language,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).sombras, size: 20),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.of(context).textoPrincipal,
                          fontSize: 13,
                        ),
                        items: _languages.map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            accessNotifier.setLanguage(val);
                            if (val == 'Español') {
                              context.setLocale(const Locale('es'));
                            } else if (val == 'English') {
                              context.setLocale(const Locale('en'));
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'restablecer'.tr(),
                  type: ButtonType.alternativo,
                  color: ButtonColor.naranja,
                  icon: Icons.refresh,
                  onPressed: () {
                    accessNotifier.reset();
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
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

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Semantics(
      label: title,
      hint: subtitle,
      toggled: value,
      child: _buildCard(context, 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: AppColors.of(context).naranjaUnimet, size: 28),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            ExcludeSemantics(
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.of(context).naranjaUnimet,
                activeTrackColor: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.of(context).sombras.withValues(alpha: 0.5),
                inactiveTrackColor: AppColors.of(context).sombras.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
