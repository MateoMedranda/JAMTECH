import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../profile/edit_profile_view.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final initiales = user?.nombre != null && user!.nombre.isNotEmpty
        ? user.nombre.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : 'U';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header perfil ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      initiales,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.nombre ?? 'Usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    'Administrador',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Secciones de menú ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMenuSeccion(
                  'Mi cuenta',
                  [
                    _MenuItemData(
                      icon: Icons.person_outline_rounded,
                      label: 'Editar perfil',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileView()),
                      ),
                    ),
                    _MenuItemData(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Información bancaria',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: Icons.receipt_long_outlined,
                      label: 'Historial de transacciones',
                      onTap: () {},
                    ),
                  ],
                  context,
                ),

                const SizedBox(height: 16),

                _buildMenuSeccion(
                  'Negocio',
                  [
                    _MenuItemData(
                      icon: Icons.group_outlined,
                      label: 'Gestionar vendedores',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: Icons.store_outlined,
                      label: 'Información del negocio',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reportes y estadísticas',
                      onTap: () {},
                      badge: 'Nuevo',
                    ),
                  ],
                  context,
                ),

                const SizedBox(height: 16),

                _buildMenuSeccion(
                  'Ayuda y soporte',
                  [
                    _MenuItemData(
                      icon: Icons.smart_toy_outlined,
                      label: 'Asistente IA',
                      onTap: () => Navigator.pushNamed(context, '/chatbot'),
                      badge: 'IA',
                      badgeColor: AppColors.primary,
                    ),
                    _MenuItemData(
                      icon: Icons.headset_mic_outlined,
                      label: 'Centro de soporte',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: Icons.help_outline_rounded,
                      label: 'Preguntas frecuentes',
                      onTap: () {},
                    ),
                  ],
                  context,
                ),

                const SizedBox(height: 16),

                _buildMenuSeccion(
                  'Configuración',
                  [
                    _MenuItemData(
                      icon: Icons.lock_outline_rounded,
                      label: 'Seguridad',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () {},
                    ),
                  ],
                  context,
                ),

                const SizedBox(height: 24),

                // Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await authController.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: Text(
                      'Cerrar sesión',
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withOpacity(0.4), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Eliminar cuenta
                TextButton(
                  onPressed: () => _showDeleteDialog(context, authController),
                  child: Text(
                    'Eliminar cuenta',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSeccion(
    String titulo,
    List<_MenuItemData> items,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.badge != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item.badgeColor ?? AppColors.teal).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.badge!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: item.badgeColor ?? AppColors.teal,
                              ),
                            ),
                          ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.greyMedium,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AuthController authController) {
    final email = authController.currentUser?.email ?? '';
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar Cuenta',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción es irreversible. Se eliminarán todos tus datos.',
              style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Escribe "eliminar $email" para confirmar:',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim() == 'eliminar $email') {
                Navigator.pop(context);
                final success = await authController.deleteAccount();
                if (context.mounted && success) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La confirmación no coincide')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('ELIMINAR', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });
}
