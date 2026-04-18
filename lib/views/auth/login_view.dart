import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      final success = await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ErrorDialog.show(
          context,
          'Error al Iniciar Sesión',
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
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Header con gradiente morado ───────────────────────────────
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.32,
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo "deuna!" style
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'jam',
                            style: AppTextStyles.logoStyle,
                          ),
                          TextSpan(
                            text: 'tech',
                            style: AppTextStyles.logoStyle.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: '!',
                            style: AppTextStyles.logoStyle.copyWith(
                              color: const Color(0xFFE9D5FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plataforma de pagos para negocios',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Formulario ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Iniciar Sesión', style: AppTextStyles.h2),
                      const SizedBox(height: 6),
                      Text(
                        'Ingresa tus credenciales para continuar',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email
                      CustomTextField(
                        label: 'Correo Electrónico',
                        hint: 'correo@empresa.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El correo electrónico es obligatorio';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Contraseña
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Olvidaste contraseña
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botón Iniciar Sesión
                      CustomButton(
                        text: 'Iniciar Sesión',
                        onPressed: _handleLogin,
                        isLoading: authController.isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
