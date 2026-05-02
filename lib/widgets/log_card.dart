import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models.dart';

class LogCard extends StatelessWidget {
  final LogEntry log;
  final VoidCallback onTap;

  const LogCard({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = logTypeById(log.type);
    final dateStr = DateFormat('d MMM yyyy').format(log.date);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderL, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(t.icon, size: 19, color: t.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.title.isNotEmpty ? log.title : t.label,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (log.cost > 0)
                        Text(
                          '\$${log.cost.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(t.label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: t.color)),
                      _dot(),
                      Text(dateStr, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.muted)),
                      _dot(),
                      Text('${NumberFormat('#,###').format(log.odometer)} km',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.muted)),
                      if (log.images.isNotEmpty) ...[
                        _dot(),
                        Icon(Icons.image_outlined, size: 12, color: AppColors.subtle),
                      ],
                    ],
                  ),
                  if (log.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        log.note,
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: AppColors.border),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
      );
}
