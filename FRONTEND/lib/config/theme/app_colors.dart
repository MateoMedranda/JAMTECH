import 'package:flutter/material.dart';

class AppColors {
  // ── Paleta principal DeUna ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6B21A8); // Morado DeUna principal
  static const Color primaryDark = Color(0xFF4C1D95); // Morado oscuro
  static const Color primaryLight = Color(0xFF9333EA); // Morado claro
  static const Color primarySurface = Color(0xFFF5F0FF); // Fondo morado suave

  // ── Acento teal (DeUna Negocios quick actions) ─────────────────────────
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFCCFBF1);

  // ── Fondo y superficies ────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);

  // ── Texto ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Estado ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // ── Neutros ────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFF3F4F6);
  static const Color greyMedium = Color(0xFFD1D5DB);

  // ── Gradientes ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6B21A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient chatbotGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFF6B21A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Mode (simplificado) ───────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0A1E);
  static const Color surfaceDark = Color(0xFF1A1030);
  static const Color inputBackgroundDark = Color(0xFF2D1F4E);
  static const Color textPrimaryDark = Color(0xFFF3F0FF);
  static const Color textSecondaryDark = Color(0xFFA78BFA);
}
