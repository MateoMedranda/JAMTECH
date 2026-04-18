import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Títulos ────────────────────────────────────────────────────────────
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Logotipo DeUna style ────────────────────────────────────────────────
  static TextStyle logoStyle = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    fontStyle: FontStyle.italic,
    letterSpacing: -1,
  );

  static TextStyle logoDark = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    fontStyle: FontStyle.italic,
    letterSpacing: -1,
  );

  // ── Montos / números grandes ───────────────────────────────────────────
  static TextStyle amountLarge = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  static TextStyle amountMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ── Cuerpo de texto ────────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── Botones ────────────────────────────────────────────────────────────
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ── Hints y labels ─────────────────────────────────────────────────────
  static TextStyle hint = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Sección headers ────────────────────────────────────────────────────
  static TextStyle sectionHeader = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  // ── Quick action labels ────────────────────────────────────────────────
  static TextStyle quickActionLabel = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}
