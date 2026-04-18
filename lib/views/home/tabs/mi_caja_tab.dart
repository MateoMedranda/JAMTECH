import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_colors.dart';

class MiCajaTab extends StatelessWidget {
  const MiCajaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Resumen del día ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de hoy',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$340.50',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip('12 ventas', Icons.receipt_rounded),
                    const SizedBox(width: 12),
                    _buildStatChip('3 vendedores', Icons.group_rounded),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Vendedores activos ────────────────────────────────────────
          Text(
            'Vendedores activos',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          _buildVendedorItem('María García', 'Vendedora', '\$125.00', 5),
          const SizedBox(height: 10),
          _buildVendedorItem('Carlos López', 'Vendedor', '\$98.50', 4),
          const SizedBox(height: 10),
          _buildVendedorItem('Ana Martínez', 'Cajera', '\$117.00', 3),

          const SizedBox(height: 24),

          // ── Botón agregar vendedor ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: Text(
                'Agregar vendedor',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Historial de caja ─────────────────────────────────────────
          Text(
            'Historial de caja',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          _buildCajaItem('Apertura de caja', '08:00 AM', '\$50.00', Icons.lock_open_rounded, AppColors.success),
          const SizedBox(height: 10),
          _buildCajaItem('Cierre parcial', '12:00 PM', '\$200.00', Icons.lock_rounded, AppColors.warning),
          const SizedBox(height: 10),
          _buildCajaItem('Ingreso QR', '14:30 PM', '+\$90.50', Icons.qr_code_rounded, AppColors.primary),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
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

  Widget _buildVendedorItem(String nombre, String rol, String monto, int ventas) {
    final initiales = nombre.split(' ').map((p) => p[0]).take(2).join();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              initiales,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$rol • $ventas ventas',
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
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCajaItem(String titulo, String hora, String monto, IconData icon, Color color) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  hora,
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
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
