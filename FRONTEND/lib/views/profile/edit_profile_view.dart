import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;

  String _selectedGender = 'Prefiero no decirlo';
  final List<String> _genders = [
    'Masculino',
    'Femenino',
    'Otro',
    'Prefiero no decirlo',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _birthdateController = TextEditingController(text: user?.birthdate ?? '');

    if (user?.gender != null && _genders.contains(user!.gender)) {
      _selectedGender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      final currentUser = authController.currentUser;
      if (currentUser == null) return;

      final updatedUser = UserModel(
        id: currentUser.id,
        nombre: _nameController.text.trim(),
        email: currentUser.email,
        password: currentUser.password,
        birthdate: _birthdateController.text.trim(),
        gender: _selectedGender,
        weight: currentUser.weight,
        height: currentUser.height,
        medicalConditions: currentUser.medicalConditions,
        medications: currentUser.medications,
        allergies: currentUser.allergies,
      );

      final success = await authController.updateProfile(updatedUser);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authController.errorMessage ?? 'Error al actualizar'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Header morado ─────────────────────────────────────────────
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
                      'Editar perfil',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Consumer<AuthController>(
              builder: (context, authController, child) {
                if (authController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Información personal', style: AppTextStyles.sectionHeader),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _nameController,
                          label: 'Nombre completo',
                          hint: 'Ingresa tu nombre',
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                          validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 18),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Correo electrónico',
                          hint: 'correo@empresa.com',
                          readOnly: true,
                          fillColor: AppColors.grey,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(height: 18),

                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _birthdateController,
                              label: 'Fecha de nacimiento',
                              hint: 'YYYY-MM-DD',
                              prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Género',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                            items: _genders.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender, style: const TextStyle(fontSize: 15)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) setState(() => _selectedGender = newValue);
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        CustomButton(
                          text: 'Guardar cambios',
                          onPressed: _saveProfile,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
