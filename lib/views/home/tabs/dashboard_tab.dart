import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _saldoVisible = false;
  final String _saldo = '\$2,450.00';

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner de saldo ─────────────────────────────────────────
            _buildSaldoCard(),

            const SizedBox(height: 24),

            // ── Accesos rápidos ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accesos rápidos', style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 16),
                  _buildAccesosRapidos(),

                  const SizedBox(height: 28),

                  // ── Novedades ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Novedades JAMTECH', style: AppTextStyles.sectionHeader),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Ver todo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Cards novedades ─────────────────────────────────────────
            _buildNovedadesScroll(),

            const SizedBox(height: 28),

            // ── Últimas transacciones ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Últimas transacciones', style: AppTextStyles.sectionHeader),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTransaccionItem(
                    'Cobro QR',
                    'Hace 10 min',
                    '+\$25.00',
                    Icons.qr_code_rounded,
                    true,
                  ),
                  const SizedBox(height: 10),
                  _buildTransaccionItem(
                    'Transferencia saliente',
                    'Ayer, 14:30',
                    '-\$100.00',
                    Icons.arrow_upward_rounded,
                    false,
                  ),
                  const SizedBox(height: 10),
                  _buildTransaccionItem(
                    'Venta manual',
                    'Ayer, 10:15',
                    '+\$75.50',
                    Icons.point_of_sale_rounded,
                    true,
                  ),
                  const SizedBox(height: 10),
                  _buildTransaccionItem(
                    'Recarga de saldo',
                    'Hace 2 días',
                    '+\$200.00',
                    Icons.add_circle_outline_rounded,
                    true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Espacio para FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Saldo',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _saldoVisible ? _saldo : '\$●●●●●●',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() => _saldoVisible = !_saldoVisible),
                        child: Icon(
                          _saldoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Badge admin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 0.5),
          const SizedBox(height: 16),

          // Acciones rápidas dentro de la card
          Row(
            children: [
              _buildCardAction(Icons.add_rounded, 'Recargar'),
              const SizedBox(width: 20),
              _buildCardAction(Icons.arrow_upward_rounded, 'Transferir'),
              const SizedBox(width: 20),
              _buildCardAction(Icons.arrow_forward_rounded, 'Ver detalle'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    final accesos = [
      _AccesoRapido(
        icon: Icons.qr_code_rounded,
        label: 'Cobrar',
        color: AppColors.primary,
        bgColor: AppColors.primarySurface,
      ),
      _AccesoRapido(
        icon: Icons.arrow_upward_rounded,
        label: 'Transferir',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
      ),
      _AccesoRapido(
        icon: Icons.add_circle_outline_rounded,
        label: 'Recargar',
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _AccesoRapido(
        icon: Icons.point_of_sale_rounded,
        label: 'Venta manual',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
      ),
      _AccesoRapido(
        icon: Icons.receipt_long_rounded,
        label: 'Historial',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
      ),
      _AccesoRapido(
        icon: Icons.verified_rounded,
        label: 'Verificar pago',
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFF0FDF4),
      ),
      _AccesoRapido(
        icon: Icons.group_add_rounded,
        label: 'Agregar vendedor',
        color: const Color(0xFF9333EA),
        bgColor: const Color(0xFFFAF5FF),
      ),
      _AccesoRapido(
        icon: Icons.bar_chart_rounded,
        label: 'Reportes',
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFFF1F2),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accesos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final acceso = accesos[index];
        return GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: acceso.bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: acceso.color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(acceso.icon, color: acceso.color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                acceso.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNovedadesScroll() {
    final novedades = [
      _Novedad(
        title: 'Agrega vendedores a tu equipo',
        subtitle: 'Gestiona tu equipo de ventas',
        color: const Color(0xFF7C3AED),
        icon: Icons.group_add_rounded,
      ),
      _Novedad(
        title: 'Administra tus ventas con Mi Caja',
        subtitle: 'Control total de tus transacciones',
        color: AppColors.teal,
        icon: Icons.point_of_sale_rounded,
      ),
      _Novedad(
        title: 'Acepta pagos con QR',
        subtitle: 'Cobra más rápido y sin efectivo',
        color: const Color(0xFF2563EB),
        icon: Icons.qr_code_scanner_rounded,
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: novedades.length,
        itemBuilder: (context, index) {
          final novedad = novedades[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: novedad.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: novedad.color.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: novedad.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(novedad.icon, color: novedad.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        novedad.title,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        novedad.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransaccionItem(
    String titulo,
    String fecha,
    String monto,
    IconData icon,
    bool esIngreso,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: esIngreso
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: esIngreso ? AppColors.success : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  fecha,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            monto,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: esIngreso ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoRapido {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  _AccesoRapido({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

class _Novedad {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  _Novedad({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
