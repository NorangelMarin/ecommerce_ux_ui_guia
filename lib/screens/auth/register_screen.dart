import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(authRepositoryProvider)
            .signUpWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _nameController.text.trim(),
            );
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          CustomNotification.show(context, message: e.toString(), type: NotificationType.error);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).naranjaUnimet),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'crea_una_cuenta_para_acceder_a_tu_espaci'.tr(),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'nete_a_la_comunidad_de_unimet_store_y_em'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 40),

                CustomTextField(
                  controller: _nameController,
                  label: 'nombre_completo'.tr(),
                  placeholder: 'Ej. Juan Pérez',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  label: 'correo_electrónico'.tr(),
                  placeholder: 'usuario@correo.com',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
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
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'confirmar_contraseña'.tr(),
                  placeholder: '****************',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debes confirmar tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.of(context).naranjaUnimet,
                        ),
                      )
                    : CustomButton(
                        text: 'registrarme'.tr(),
                        color: ButtonColor.naranja,
                        onPressed: _register,
                        icon: Icons.person_add,
                      ),
                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ya_tengo_una_cuenta'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Color(0xFF666666), // AppColors.of(context).sombras
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                CustomButton(
                  text: 'iniciar_sesion'.tr(),
                  type: ButtonType.alternativo,
                  color: ButtonColor.naranja,
                  icon: Icons.login,
                  onPressed: () => context.go('/'),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
