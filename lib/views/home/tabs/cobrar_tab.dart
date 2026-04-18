import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_colors.dart';

class CobrarTab extends StatefulWidget {
  const CobrarTab({super.key});

  @override
  State<CobrarTab> createState() => _CobrarTabState();
}

class _CobrarTabState extends State<CobrarTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _monto = '0';
  String _motivo = '';
  bool _motivoExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _presionarTecla(String valor) {
    HapticFeedback.lightImpact();
    setState(() {
      if (valor == 'DEL') {
        if (_monto.length > 1) {
          _monto = _monto.substring(0, _monto.length - 1);
        } else {
          _monto = '0';
        }
      } else if (valor == '.') {
        if (!_monto.contains('.')) {
          _monto = '$_monto.';
        }
      } else {
        if (_monto == '0') {
          _monto = valor;
        } else if (_monto.contains('.')) {
          final decimalPart = _monto.split('.')[1];
          if (decimalPart.length < 2) {
            _monto = '$_monto$valor';
          }
        } else if (_monto.length < 8) {
          _monto = '$_monto$valor';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Monto grande ─────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Tabs QR / Tarjeta / Manual
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.all(3),
                    tabs: const [
                      Tab(text: 'QR'),
                      Tab(text: 'Tarjeta'),
                      Tab(text: 'Manual'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Monto
                Text(
                  'Monto',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _monto,
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Agregar motivo
                GestureDetector(
                  onTap: () {
                    setState(() => _motivoExpanded = !_motivoExpanded);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _motivo.isEmpty ? 'Agregar motivo (opcional)' : _motivo,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _motivo.isEmpty ? AppColors.textHint : AppColors.textPrimary,
                          ),
                        ),
                        Icon(
                          _motivoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_motivoExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                    child: TextField(
                      autofocus: true,
                      onChanged: (val) => setState(() => _motivo = val),
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ej: Almuerzo, servicio, etc.',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Teclado numérico ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              children: [
                _buildFila(['1', '2', '3']),
                const SizedBox(height: 8),
                _buildFila(['4', '5', '6']),
                const SizedBox(height: 8),
                _buildFila(['7', '8', '9']),
                const SizedBox(height: 8),
                _buildFila(['.', '0', 'DEL']),
              ],
            ),
          ),

          // ── Botón continuar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _monto != '0' && _monto != '0.'
                    ? () {
                        // TODO: Conectar con backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Procesando cobro de \$$_monto...',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.greyMedium,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  'Continuar para Cobrar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFila(List<String> teclas) {
    return Row(
      children: teclas.map((tecla) {
        final esDel = tecla == 'DEL';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _presionarTecla(tecla),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: esDel ? AppColors.primarySurface : AppColors.grey,
                  borderRadius: BorderRadius.circular(14),
                  border: esDel ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
                ),
                child: Center(
                  child: esDel
                      ? const Icon(Icons.backspace_outlined, color: AppColors.primary, size: 22)
                      : Text(
                          tecla,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
