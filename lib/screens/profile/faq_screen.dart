import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/floating_chat_button.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/guide_wrapper.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'question': '¿Cómo reportar pagos?',
      'answer':
          'Para reportar un problema con tu pago, dirígete a "Soporte" y selecciona la opción "Reportar problema de pago". Nuestro equipo revisará tu caso en menos de 24 horas.',
    },
    {
      'question': '¿Cuánto tarda el delivery?',
      'answer':
          'El tiempo de entrega varía según tu ubicación. En el área metropolitana, el promedio es de 2 a 4 días hábiles. Para el interior del país, entre 5 y 8 días hábiles.',
    },
    {
      'question': 'Políticas de cancelación',
      'answer':
          'Puedes cancelar tu pedido dentro de las primeras 2 horas después de realizarlo. Pasado ese tiempo, si el pedido ya está en preparación no será posible cancelarlo.',
    },
    {
      'question': 'Políticas de devolución',
      'answer':
          'Si recibes un producto defectuoso, incorrecto o en mal estado, puedes iniciar una devolución dentro de los 15 días hábiles siguientes a la entrega. El producto debe estar en su empaque original, sin uso y con todos sus accesorios. Una vez aprobada la solicitud, procesaremos el reembolso a tu método de pago original en un plazo de 5 a 7 días hábiles.',
      'note': 'Recuerda que tienes un plazo de 15 días hábiles para realizar cualquier reclamo.',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) => faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      floatingActionButton: FloatingChatButton(),
      appBar: TopNavigationBar(
        titleWidget: GuideWrapper(
          id: 'faq_title',
          title: 'Preguntas Frecuentes',
          description: 'Ofrecer una sección de preguntas frecuentes ayuda al usuario a resolver dudas de manera autónoma y rápida, reduciendo la carga de soporte al cliente.',
          child: Text('preguntas_frecuentes'.tr(),
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textoPrincipal,
            ),
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: GuideWrapper(
              id: 'faq_search',
              title: 'Buscador Predictivo',
              description: 'Incluir una barra de búsqueda en las FAQ permite a los usuarios encontrar soluciones específicas sin tener que navegar por toda la lista, ahorrando tiempo y esfuerzo.',
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.of(context).blanco,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.15)),
                ),
              child: TextField(
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _expandedIndex = null;
                }),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'buscar_duda'.tr(),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.of(context).sombras.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.of(context).sombras, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              ),
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              children: [
                ..._filteredFaqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  final isExpanded = _expandedIndex == i;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _buildFaqItem(theme, i, faq, isExpanded),
                  );
                }),
                SizedBox(height: 16),
                _buildSupportCard(context),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Soporte activo
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }

  Widget _buildFaqItem(ThemeData theme, int index, Map<String, String> faq, bool isExpanded) {
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    faq['question']!,
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
                faq['answer']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).sombras,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (faq['note'] != null) ...[
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
                          faq['note']!,
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

  Widget _buildSupportCard(BuildContext context) {
    final theme = Theme.of(context);
    return GuideWrapper(
      id: 'faq_support_card',
      title: 'Escalamiento de Soporte',
      description: 'Ofrecer una opción clara para contactar a soporte al final de las FAQ garantiza que el usuario no se sienta abandonado si su duda no fue resuelta.',
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
          Text('nuestro_equipo_de_soporte_est_disponible'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.push('/support'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.15) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: theme.brightness == Brightness.dark 
                    ? Border.all(color: Colors.white.withValues(alpha: 0.3)) 
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline, 
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : AppColors.of(context).azulSistemas, 
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text('contactar_con_soporte'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark 
                          ? Colors.white 
                          : AppColors.of(context).azulSistemas,
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
      ),
    );
  }
}
