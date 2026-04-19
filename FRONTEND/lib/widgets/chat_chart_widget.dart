import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme/app_colors.dart';
import 'chart_data_parser.dart';

// Paleta de colores para los gráficos
const _chartColors = [
  Color(0xFF7C3AED),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
];

class ChatChartWidget extends StatelessWidget {
  final ParsedChartData data;
  const ChatChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExpandedChart(context),
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6B21A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Ver más',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Mini chart preview
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 140,
                child: _buildChart(data, compact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpandedChart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpandedChartSheet(data: data),
    );
  }
}

// ── Selector de gráfico ────────────────────────────────────────────────────

Widget _buildChart(ParsedChartData data, {bool compact = false}) {
  switch (data.suggestedType) {
    case ChartType.bar:
      return _BarChartView(data: data, compact: compact);
    case ChartType.line:
      return _LineChartView(data: data, compact: compact);
    case ChartType.pie:
    case ChartType.donut:
      return _PieChartView(data: data, compact: compact, isDonut: data.suggestedType == ChartType.donut);
  }
}

// ── Barra ─────────────────────────────────────────────────────────────────

class _BarChartView extends StatefulWidget {
  final ParsedChartData data;
  final bool compact;
  const _BarChartView({required this.data, required this.compact});

  @override
  State<_BarChartView> createState() => _BarChartViewState();
}

class _BarChartViewState extends State<_BarChartView> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final points = widget.data.points;
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.25,
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            if (!widget.compact) {
              setState(() {
                _touched = response?.spot?.touchedBarGroupIndex;
              });
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final p = points[groupIndex];
              return BarTooltipItem(
                '${p.label}\n${p.displayValue ?? p.value.toStringAsFixed(1)}',
                GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                final label = points[idx].label;
                final short = label.length > 6 ? '${label.substring(0, 5)}…' : label;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    short,
                    style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: !widget.compact,
          drawVerticalLine: false,
          horizontalInterval: maxVal / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(points.length, (i) {
          final isTouched = _touched == i;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: points[i].value,
                width: widget.compact ? 14 : 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  colors: isTouched
                      ? [_chartColors[i % _chartColors.length], _chartColors[i % _chartColors.length].withOpacity(0.6)]
                      : [_chartColors[i % _chartColors.length].withOpacity(0.9), _chartColors[i % _chartColors.length].withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal * 1.25,
                  color: _chartColors[i % _chartColors.length].withOpacity(0.05),
                ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Línea ─────────────────────────────────────────────────────────────────

class _LineChartView extends StatelessWidget {
  final ParsedChartData data;
  final bool compact;
  const _LineChartView({required this.data, required this.compact});

  @override
  Widget build(BuildContext context) {
    final points = data.points;
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minVal = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        minY: minVal * 0.8,
        maxY: maxVal * 1.2,
        lineTouchData: LineTouchData(
          enabled: !compact,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (spots) => spots.map((s) {
              final p = points[s.spotIndex];
              return LineTooltipItem(
                '${p.label}\n${p.displayValue ?? p.value.toStringAsFixed(1)}',
                GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: !compact,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                final label = points[idx].label;
                final short = label.length > 5 ? '${label.substring(0, 4)}…' : label;
                return Text(short, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(points.length, (i) => FlSpot(i.toDouble(), points[i].value)),
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: compact ? 3 : 5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Pie / Donut ────────────────────────────────────────────────────────────

class _PieChartView extends StatefulWidget {
  final ParsedChartData data;
  final bool compact;
  final bool isDonut;
  const _PieChartView({required this.data, required this.compact, required this.isDonut});

  @override
  State<_PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends State<_PieChartView> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final points = widget.data.points;
    final total = points.fold(0.0, (s, p) => s + p.value);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: widget.isDonut ? (widget.compact ? 28 : 48) : 0,
        pieTouchData: PieTouchData(
          enabled: !widget.compact,
          touchCallback: (event, response) {
            setState(() {
              _touched = response?.touchedSection?.touchedSectionIndex;
            });
          },
        ),
        sections: List.generate(points.length, (i) {
          final isTouched = _touched == i;
          final pct = (points[i].value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            color: _chartColors[i % _chartColors.length],
            value: points[i].value,
            radius: isTouched ? (widget.compact ? 48 : 72) : (widget.compact ? 42 : 64),
            title: widget.compact ? '' : '$pct%',
            titleStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: isTouched && !widget.compact
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                    ),
                    child: Text(
                      '${points[i].label}\n${points[i].displayValue ?? pct + "%"}',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            badgePositionPercentageOffset: 1.3,
          );
        }),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Modal expandido ────────────────────────────────────────────────────────

class _ExpandedChartSheet extends StatefulWidget {
  final ParsedChartData data;
  const _ExpandedChartSheet({required this.data});

  @override
  State<_ExpandedChartSheet> createState() => _ExpandedChartSheetState();
}

class _ExpandedChartSheetState extends State<_ExpandedChartSheet> {
  late ChartType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.data.suggestedType;
  }

  ParsedChartData get _currentData => ParsedChartData(
        points: widget.data.points,
        suggestedType: _currentType,
        title: widget.data.title,
        unit: widget.data.unit,
      );

  @override
  Widget build(BuildContext context) {
    final points = widget.data.points;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6B21A8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_graph_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.data.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Tipo de gráfico selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ChipType(
                  label: 'Barras',
                  icon: Icons.bar_chart_rounded,
                  selected: _currentType == ChartType.bar,
                  onTap: () => setState(() => _currentType = ChartType.bar),
                ),
                const SizedBox(width: 8),
                _ChipType(
                  label: 'Líneas',
                  icon: Icons.show_chart_rounded,
                  selected: _currentType == ChartType.line,
                  onTap: () => setState(() => _currentType = ChartType.line),
                ),
                const SizedBox(width: 8),
                _ChipType(
                  label: 'Circular',
                  icon: Icons.pie_chart_rounded,
                  selected: _currentType == ChartType.pie || _currentType == ChartType.donut,
                  onTap: () => setState(() => _currentType = ChartType.donut),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildChart(_currentData, compact: false),
              ),
            ),
          ),
          // Leyenda / tabla de datos
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalle',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: List.generate(points.length, (i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _chartColors[i % _chartColors.length].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _chartColors[i % _chartColors.length].withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _chartColors[i % _chartColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${points[i].label}: ${points[i].displayValue ?? points[i].value.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipType extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ChipType({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
