// chart_data_parser.dart

/// Tipos de gráfico soportados
enum ChartType { bar, line, pie, donut }

/// Un punto de dato para el gráfico
class ChartDataPoint {
  final String label;
  final double value;
  final String? displayValue; // Ej: "$1,200" o "45%"

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.displayValue,
  });
}

/// Resultado del parseo
class ParsedChartData {
  final List<ChartDataPoint> points;
  final ChartType suggestedType;
  final String title;
  final String? unit; // "$", "%", etc.

  const ParsedChartData({
    required this.points,
    required this.suggestedType,
    required this.title,
    this.unit,
  });
}

/// Parsea el texto de un mensaje del bot y extrae datos para graficar.
/// Retorna null si no hay suficientes datos numéricos.
class ChartDataParser {
  static ParsedChartData? parse(String text) {
    // Limpiar markdown básico
    final clean = text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'\1')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll(RegExp(r'`[^`]*`'), '');

    // Intentar extraer de tabla markdown primero
    final tableResult = _parseMarkdownTable(text);
    if (tableResult != null) return tableResult;

    // Intentar extraer de listas con valores
    final listResult = _parseListWithValues(clean);
    if (listResult != null) return listResult;

    // Intentar extraer de pares clave:valor en el texto
    final keyValueResult = _parseKeyValuePairs(clean);
    if (keyValueResult != null) return keyValueResult;

    return null;
  }

  // ── Tabla Markdown ────────────────────────────────────────────────────────
  static ParsedChartData? _parseMarkdownTable(String text) {
    final lines = text.split('\n');
    final tableLines = <String>[];
    bool inTable = false;

    for (final line in lines) {
      if (line.trim().startsWith('|')) {
        inTable = true;
        tableLines.add(line.trim());
      } else if (inTable) {
        break;
      }
    }

    if (tableLines.length < 3) return null; // header + separator + at least 1 row

    // Parsear encabezados
    final headers = _splitTableRow(tableLines[0]);
    if (headers.length < 2) return null;

    // Encontrar la columna numérica
    int? numColIndex;
    String? numColHeader;
    for (int i = 1; i < headers.length; i++) {
      final header = headers[i].trim();
      if (_looksNumericHeader(header)) {
        numColIndex = i;
        numColHeader = header;
        break;
      }
    }

    if (numColIndex == null) {
      // Intentar con la última columna
      numColIndex = headers.length - 1;
      numColHeader = headers[numColIndex].trim();
    }

    final labelColIndex = 0;
    final points = <ChartDataPoint>[];
    String? unit;

    for (int i = 2; i < tableLines.length; i++) {
      final cells = _splitTableRow(tableLines[i]);
      if (cells.length <= numColIndex!) continue;

      final label = _cleanLabel(cells[labelColIndex].trim());
      final rawVal = cells[numColIndex].trim();
      final parsed = _parseNumber(rawVal);

      if (parsed == null || label.isEmpty) continue;
      if (unit == null) unit = _extractUnit(rawVal);

      points.add(ChartDataPoint(
        label: label,
        value: parsed,
        displayValue: rawVal.isEmpty ? _formatNum(parsed, unit) : rawVal,
      ));
    }

    if (points.length < 2) return null;

    return ParsedChartData(
      points: points,
      suggestedType: _suggestType(points, numColHeader ?? ''),
      title: _buildTitle(numColHeader ?? 'Datos', unit),
      unit: unit,
    );
  }

  // ── Listas con valores ────────────────────────────────────────────────────
  static ParsedChartData? _parseListWithValues(String text) {
    // Patrones como: "• Ventas: $1,200" o "- Enero: 45%" o "* Total: 500"
    final pattern = RegExp(
      r'(?:^|\n)\s*[-•*]\s*([^:\n]{2,40}):\s*([\$\€\£]?\s*[\d,._]+\s*[%\$\€\£KMk]?)',
      multiLine: true,
    );

    final matches = pattern.allMatches(text).toList();
    if (matches.length < 2) return null;

    final points = <ChartDataPoint>[];
    String? unit;

    for (final m in matches) {
      final label = _cleanLabel(m.group(1)?.trim() ?? '');
      final rawVal = m.group(2)?.trim() ?? '';
      final parsed = _parseNumber(rawVal);

      if (parsed == null || label.isEmpty) continue;
      if (unit == null) unit = _extractUnit(rawVal);

      points.add(ChartDataPoint(
        label: label,
        value: parsed,
        displayValue: rawVal,
      ));
    }

    if (points.length < 2) return null;

    // Inferir título buscando contexto previo
    final title = _inferTitle(text, unit);

    return ParsedChartData(
      points: points,
      suggestedType: _suggestType(points, title),
      title: title,
      unit: unit,
    );
  }

  // ── Pares clave:valor en prosa ────────────────────────────────────────────
  static ParsedChartData? _parseKeyValuePairs(String text) {
    // "Ventas totales: $5,000\nGastos: $2,000\nGanancia: $3,000"
    final pattern = RegExp(
      r'([A-Za-záéíóúÁÉÍÓÚñÑ][^\n:]{1,35}):\s*([\$\€\£]?\s*[\d,._]+\s*[%\$\€\£KMk]?)',
      multiLine: true,
    );

    final matches = pattern.allMatches(text).toList();
    if (matches.length < 3) return null;

    final points = <ChartDataPoint>[];
    String? unit;

    for (final m in matches) {
      final label = _cleanLabel(m.group(1)?.trim() ?? '');
      final rawVal = m.group(2)?.trim() ?? '';
      final parsed = _parseNumber(rawVal);

      if (parsed == null || label.isEmpty || label.length > 35) continue;
      if (unit == null) unit = _extractUnit(rawVal);

      points.add(ChartDataPoint(
        label: label,
        value: parsed,
        displayValue: rawVal,
      ));
    }

    if (points.length < 3) return null;

    final title = _inferTitle(text, unit);

    return ParsedChartData(
      points: points,
      suggestedType: _suggestType(points, title),
      title: title,
      unit: unit,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<String> _splitTableRow(String row) {
    return row
        .split('|')
        .where((s) => s.trim().isNotEmpty && !RegExp(r'^[-:\s]+$').hasMatch(s.trim()))
        .toList();
  }

  static double? _parseNumber(String raw) {
    if (raw.trim().isEmpty) return null;
    // Quitar símbolos de moneda, espacios, etc.
    var clean = raw.replaceAll(RegExp(r'[\$\€\£\s,_]'), '');

    // Manejar K y M
    double multiplier = 1;
    if (clean.endsWith('K') || clean.endsWith('k')) {
      multiplier = 1000;
      clean = clean.substring(0, clean.length - 1);
    } else if (clean.endsWith('M') || clean.endsWith('m')) {
      multiplier = 1000000;
      clean = clean.substring(0, clean.length - 1);
    }

    // Quitar %
    clean = clean.replaceAll('%', '');

    final val = double.tryParse(clean);
    return val != null ? val * multiplier : null;
  }

  static String? _extractUnit(String raw) {
    if (raw.contains('%')) return '%';
    if (raw.contains('\$')) return '\$';
    if (raw.contains('€')) return '€';
    if (raw.contains('£')) return '£';
    return null;
  }

  static String _cleanLabel(String label) {
    return label
        .replaceAll(RegExp(r'^[-•*\s]+'), '')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .trim();
  }

  static bool _looksNumericHeader(String header) {
    final lower = header.toLowerCase();
    return lower.contains('valor') ||
        lower.contains('total') ||
        lower.contains('monto') ||
        lower.contains('cantidad') ||
        lower.contains('ventas') ||
        lower.contains('ingresos') ||
        lower.contains('gastos') ||
        lower.contains('precio') ||
        lower.contains('amount') ||
        lower.contains('\$') ||
        lower.contains('%');
  }

  static String _inferTitle(String text, String? unit) {
    // Buscar la primera línea que parezca un título (negrita o mayúsculas)
    final boldTitle = RegExp(r'\*\*([^*\n]{3,50})\*\*').firstMatch(text);
    if (boldTitle != null) {
      return _cleanLabel(boldTitle.group(1) ?? '');
    }

    // Primera línea no vacía
    final firstLine = text
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty && l.length > 3, orElse: () => '');

    if (firstLine.isNotEmpty && firstLine.length < 60) {
      return _cleanLabel(firstLine);
    }

    if (unit == '%') return 'Distribución porcentual';
    if (unit == '\$') return 'Resumen financiero';
    return 'Resumen de datos';
  }

  static String _buildTitle(String colHeader, String? unit) {
    final lower = colHeader.toLowerCase();
    if (lower.contains('venta')) return 'Ventas';
    if (lower.contains('gasto')) return 'Gastos';
    if (lower.contains('ingreso')) return 'Ingresos';
    if (lower.contains('total')) return 'Totales';
    if (unit == '%') return 'Distribución porcentual';
    return colHeader;
  }

  static ChartType _suggestType(List<ChartDataPoint> points, String hint) {
    final lower = hint.toLowerCase();

    // Porcentajes → pie/donut
    if (lower.contains('%') ||
        lower.contains('porcentaje') ||
        lower.contains('distribuci')) {
      final total = points.fold(0.0, (s, p) => s + p.value);
      if (total >= 90 && total <= 110) return ChartType.donut;
    }

    // Tendencia temporal → línea
    final hasTimeLabels = points.any((p) {
      final l = p.label.toLowerCase();
      return l.contains('ene') ||
          l.contains('feb') ||
          l.contains('mar') ||
          l.contains('abr') ||
          l.contains('may') ||
          l.contains('jun') ||
          l.contains('jul') ||
          l.contains('ago') ||
          l.contains('sep') ||
          l.contains('oct') ||
          l.contains('nov') ||
          l.contains('dic') ||
          l.contains('q1') ||
          l.contains('q2') ||
          l.contains('q3') ||
          l.contains('q4') ||
          RegExp(r'^\d{4}$').hasMatch(p.label) ||
          RegExp(r'semana', caseSensitive: false).hasMatch(l);
    });

    if (hasTimeLabels && points.length >= 3) return ChartType.line;

    // Default: barras
    return ChartType.bar;
  }

  static String _formatNum(double val, String? unit) {
    if (unit == '%') return '${val.toStringAsFixed(1)}%';
    if (unit == '\$') {
      if (val >= 1000000) return '\$${(val / 1000000).toStringAsFixed(1)}M';
      if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}K';
      return '\$${val.toStringAsFixed(2)}';
    }
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }
}
