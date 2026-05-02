import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../models.dart';

class LogTypeGrid extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelect;

  const LogTypeGrid({super.key, required this.selectedType, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: logTypes.map((lt) {
        final active = selectedType == lt.id;
        return GestureDetector(
          onTap: () => onSelect(lt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: active ? lt.bgColor : AppColors.card,
              border: Border.all(
                color: active ? lt.color : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: active ? lt.bgColor : AppColors.bg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(lt.icon, size: 16, color: active ? lt.color : AppColors.subtle),
                ),
                const SizedBox(height: 5),
                Text(
                  lt.label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? lt.color : AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
