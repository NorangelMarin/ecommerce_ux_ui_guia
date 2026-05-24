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
      backgroundColor: AppColors.fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Accesibilidad y personalización',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
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
              'Diseña tu experiencia visual',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.textoPrincipal,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Personaliza el entorno de Unimet Store para que se adapte perfectamente a tus necesidades.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.sombras,
                height: 1.4,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 32),

            // Tamaño del texto
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields, color: AppColors.naranjaUnimet, size: 28),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tamaño del texto',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ajusta la escala tipográfica global.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.sombras,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.naranjaUnimet,
                      thumbColor: AppColors.naranjaUnimet,
                      inactiveTrackColor: AppColors.sombras.withValues(alpha: 0.2),
                      overlayColor: AppColors.naranjaUnimet.withValues(alpha: 0.1),
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
                        Text('Pequeño', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.sombras, fontSize: 11)),
                        Text('Grande', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.sombras, fontSize: 11)),
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
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language, color: AppColors.naranjaUnimet, size: 28),
                  SizedBox(height: 12),
                  Text(
                    'Región e Idioma',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'SELECCIONA EL IDIOMA',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.sombras,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.sombras.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: accessState.language,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.sombras, size: 20),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoPrincipal,
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

            // Botón Restablecer
            Center(
              child: SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Restablecer',
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

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
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
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.naranjaUnimet, size: 28),
                SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.sombras,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.naranjaUnimet,
            activeTrackColor: AppColors.naranjaUnimet.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.sombras.withValues(alpha: 0.5),
            inactiveTrackColor: AppColors.sombras.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}
