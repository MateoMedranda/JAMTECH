import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme/app_colors.dart';

class BotResponse extends StatelessWidget {
  final String text;

  const BotResponse({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 2),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Icon(
                Icons.auto_awesome,
                size: 30,
                color: AppColors.primary,
              ),
            ),
          ),

          Expanded(
            child: Markdown(
              data: text,
              selectable: false, // ahora sí se respeta
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                h1: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                h2: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                h3: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                strong: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                code: GoogleFonts.robotoMono(
                  backgroundColor: AppColors.grey,
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquote: GoogleFonts.poppins(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}