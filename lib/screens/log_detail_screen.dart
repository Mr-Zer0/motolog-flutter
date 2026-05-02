import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models.dart';
import 'log_form_screen.dart';

class LogDetailScreen extends StatefulWidget {
  final LogEntry log;
  const LogDetailScreen({super.key, required this.log});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  late LogEntry _log;

  @override
  void initState() {
    super.initState();
    _log = widget.log;
  }

  @override
  Widget build(BuildContext context) {
    final t = logTypeById(_log.type);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Nav header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderL)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.chevron_left, size: 18, color: AppColors.accent),
                        Text('Back',
                            style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.accent)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text('Log Detail',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.push<LogEntry?>(
                        context,
                        _slideRoute(LogFormScreen(initial: _log)),
                      );
                      if (updated != null) setState(() => _log = updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 14, color: AppColors.accentText),
                          const SizedBox(width: 5),
                          Text('Edit',
                              style: GoogleFonts.outfit(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentText)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: t.bgColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(t.icon, size: 26, color: t.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _log.title.isNotEmpty ? _log.title : t.label,
                              style: GoogleFonts.outfit(
                                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            const SizedBox(height: 2),
                            Text(t.label,
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: t.color)),
                            const SizedBox(height: 2),
                            Text(DateFormat('d MMM yyyy').format(_log.date),
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  _detailRow('Odometer', '${NumberFormat('#,###').format(_log.odometer)} km'),
                  _detailRow('Cost', _log.cost > 0 ? '\$${_log.cost.toStringAsFixed(2)}' : '—'),
                  _detailRow('Notes', _log.note.isNotEmpty ? _log.note : '—', lastBorder: _log.images.isEmpty),

                  // Photos
                  if (_log.images.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('PHOTOS',
                        style: GoogleFonts.outfit(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.muted, letterSpacing: 0.9)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _log.images.map((path) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: path.startsWith('http')
                                ? Image.network(path, width: 100, height: 100, fit: BoxFit.cover)
                                : Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover),
                          )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool lastBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderL, width: lastBorder ? 0 : 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppColors.muted, letterSpacing: 0.9)),
          const SizedBox(height: 5),
          Text(value,
              style: GoogleFonts.outfit(fontSize: 15, color: AppColors.text, height: 1.5)),
        ],
      ),
    );
  }
}

PageRoute<T> _slideRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (ctx, a1, a2) => page,
      transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.fastEaseInToSlowEaseOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
