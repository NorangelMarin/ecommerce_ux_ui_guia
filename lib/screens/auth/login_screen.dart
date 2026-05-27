import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/unimet_logo.dart';
import '../../theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider).signInWithEmail(
          _emailController.text.trim(), 
          _passwordController.text.trim()
        );
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            )
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCred = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (userCred != null && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              
              // Logo de la app (Figuras)
              Center(child: UnimetLogo(size: 80)),
              SizedBox(height: 32),

              // Títulos
              Text('bienvenido_a_tu_gua_digital_interactiva'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 12),
              Text('gestiona_tu_inventario_con_el_estilo_y_l'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Color(0xFF666666), // Sombras
                ),
              ),
              SizedBox(height: 48),
              
              // Inputs
              CustomTextField(
                controller: _emailController,
                label: 'correo_electrónico'.tr(),
                placeholder: 'usuario@correo.com',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              CustomTextField(
                controller: _passwordController,
                label: 'contraseña'.tr(),
                placeholder: '****************',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),

              // Botones Principales
              _isLoading 
                  ? Center(child: CircularProgressIndicator(color: AppColors.of(context).naranjaUnimet))
                  : CustomButton(
                      text: 'iniciar_sesion'.tr(),
                      color: ButtonColor.naranja,
                      onPressed: _login,
                      icon: Icons.login,
                    ),
              SizedBox(height: 24),

              // Divisor
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.tertiary, // Verde Saman
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('o_continuar_con'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.tertiary, // Verde Saman
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Botón Alternativo
              CustomButton(
                text: 'acceder_con_google'.tr(),
                type: ButtonType.alternativo,
                color: ButtonColor.naranja, // Cambiado a Naranja
                onPressed: _isLoading ? () {} : _loginWithGoogle,
              ),
              SizedBox(height: 48),

              // Enlace final
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text('no_tengo_una_cuenta'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.tertiary, // Verde Saman
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
