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
  String _monto = '5';
  String _motivo = '';
  bool _motivoExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      } else if (valor == ',') {
        if (!_monto.contains(',')) {
          _monto = '$_monto,';
        }
      } else {
        if (_monto == '0') {
          _monto = valor;
        } else if (_monto.contains(',')) {
          final decimalPart = _monto.split(',')[1];
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Monto grande ─────────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Monto Text
                Text(
                  'Monto',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _monto,
                      style: GoogleFonts.poppins(
                        fontSize: 72,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Tabs QR / Manual
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.primaryDark,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'QR'),
                      Tab(text: 'Manual'),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Agregar motivo
                const Divider(height: 1, color: AppColors.divider),
                GestureDetector(
                  onTap: () {
                    setState(() => _motivoExpanded = !_motivoExpanded);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _motivo.isEmpty ? 'Agregar motivo (opcional)' : _motivo,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          _motivoExpanded ? Icons.keyboard_arrow_up : Icons.chevron_right_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),

                if (_motivoExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                          borderSide: BorderSide.none,
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
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              children: [
                _buildFila(['1', '2', '3']),
                _buildFila(['4', '5', '6']),
                _buildFila(['7', '8', '9']),
                _buildFila([',', '0', 'DEL']),
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
                onPressed: _monto != '0' && _monto != '0,'
                    ? () {
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
                  backgroundColor: AppColors.primaryDark,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: teclas.map((tecla) {
        final esDel = tecla == 'DEL';
        return Expanded(
          child: GestureDetector(
            onTap: () => _presionarTecla(tecla),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 64,
              child: Center(
                child: esDel
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.backspace_rounded, color: Colors.white, size: 20),
                      )
                    : Text(
                        tecla,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryDark,
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
