import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      final success = await authController.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('¡Contraseña restablecida!', style: AppTextStyles.h3),
            content: Text(
              'Tu contraseña ha sido cambiada exitosamente.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ErrorDialog.show(
          context,
          'Error',
          authController.errorMessage ?? 'Ocurrió un error inesperado',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Nueva contraseña',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Ingresa el código',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Copia el código que enviamos a tu correo y crea tu nueva contraseña.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 36),

                    CustomTextField(
                      label: 'Código de Verificación',
                      hint: 'Pega el código aquí',
                      controller: _tokenController,
                      prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El código es obligatorio';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      label: 'Nueva Contraseña',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: 'Restablecer Contraseña',
                      onPressed: _handleResetPassword,
                      isLoading: authController.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
