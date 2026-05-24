import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Guía de Diseño E-Commerce',
      'subtitle': 'Un entorno interactivo basado en la investigación "Usabilidad y experiencia de usuario en el comercio electrónico de Caracas".',
      'icon': Icons.book,
    },
    {
      'title': 'Accesibilidad y Usabilidad',
      'subtitle': 'Descubre cómo crear interfaces inclusivas, eficientes y centradas en el usuario siguiendo buenas prácticas de diseño.',
      'icon': Icons.accessibility_new,
    },
    {
      'title': 'Dos Formas de Explorar',
      'subtitle': 'Usa el "Modo Usuario" para vivir la experiencia de compra, o activa el "Modo Guía" para ver tooltips explicativos sobre las decisiones de diseño.',
      'icon': Icons.lightbulb_outline,
    },
    {
      'title': '¡Empieza a Explorar!',
      'subtitle': 'Crea una cuenta o inicia sesión para poner a prueba los conceptos desarrollados en esta guía digital.',
      'icon': Icons.rocket_launch,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      body: SafeArea(
        child: Column(
          children: [
            // Botón Saltar
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'Saltar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.sombras,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Contenido Principal
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _pages[index]['icon'],
                          size: 100,
                          color: AppColors.naranjaUnimet,
                        ),
                        SizedBox(height: 48),
                        Text(
                          _pages[index]['title'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoPrincipal,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _pages[index]['subtitle'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.sombras,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Paginación y Botones
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? AppColors.naranjaUnimet 
                              : AppColors.sombras.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _currentPage == _pages.length - 1 ? 'Entrar' : 'Siguiente',
                      color: ButtonColor.naranja,
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/');
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
