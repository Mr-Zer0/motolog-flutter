import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../widgets/log_card.dart';
import 'log_detail_screen.dart';
import 'log_form_screen.dart';
import 'bike_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  Map<String, List<LogEntry>> _groupByMonth(List<LogEntry> logs) {
    final map = <String, List<LogEntry>>{};
    for (final l in logs) {
      final key = DateFormat('MMMM yyyy').format(l.date);
      map.putIfAbsent(key, () => []).add(l);
    }
    return map;
  }

  Future<void> _exportCsv(AppState state) async {
    final csv = state.buildCsv();
    final dir = await getTemporaryDirectory();
    final name = state.bike.name.replaceAll(' ', '_');
    final file = File('${dir.path}/${name}_logs.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: '${state.bike.name} Logs');
  }

  void _showExportSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Logs', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 4),
            Text('${state.logs.length} entries · ${state.bike.name}',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportCsv(state);
                },
                icon: const Icon(Icons.download, color: AppColors.surface),
                label: Text('Download CSV',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.surface)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                child: Text('Cancel', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final filtered = state.filteredLogs(_filter);
        final grouped = _groupByMonth(filtered);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: state.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bike header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('My Bike',
                                          style: GoogleFonts.outfit(
                                              fontSize: 11, fontWeight: FontWeight.w700,
                                              color: AppColors.muted, letterSpacing: 1.0)),
                                      const SizedBox(height: 1),
                                      Text(state.bike.name,
                                          style: GoogleFonts.outfit(
                                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 1),
                                      Text('${state.bike.year} · ${state.bike.plate}',
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.subtle)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _iconBtn(Icons.download, () => _showExportSheet(context, state)),
                                    const SizedBox(width: 8),
                                    _iconBtn(Icons.edit_outlined, () {
                                      Navigator.push(context, _slideRoute(BikeScreen(bike: state.bike)));
                                    }),
                                    const SizedBox(width: 8),
                                    _iconBtn(Icons.logout, () => AuthService.signOut()),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Stats row
                            Row(
                              children: [
                                _statCard('Odometer', '${(state.currentOdometer / 1000).toStringAsFixed(1)}k km'),
                                const SizedBox(width: 8),
                                _statCard('Total Logs', '${state.logs.length}'),
                                const SizedBox(width: 8),
                                _statCard('Total Spent', '\$${state.totalCost.toStringAsFixed(0)}'),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Filter chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterChip('all', 'All', AppColors.accent, AppColors.accentBg, AppColors.accentText),
                                  ...logTypes.map((t) => _filterChip(t.id, t.label.split(' ')[0], t.color, t.bgColor, t.color)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),

                    // Log list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                      sliver: grouped.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 48),
                                child: Center(
                                  child: Text('No logs found',
                                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.muted)),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final entries = grouped.entries.toList();
                                  final month = entries[i].key;
                                  final logs = entries[i].value;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 18, 0, 4),
                                        child: Text(month,
                                            style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.muted,
                                                letterSpacing: 0.9)),
                                      ),
                                      ...logs.map((log) => LogCard(
                                            log: log,
                                            onTap: () => Navigator.push(
                                              context,
                                              _slideRoute(LogDetailScreen(log: log)),
                                            ),
                                          )),
                                    ],
                                  );
                                },
                                childCount: grouped.length,
                              ),
                            ),
                    ),
                  ],
                ),

                // FAB
                Positioned(
                  bottom: 30,
                  right: 22,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, _slideRoute(const LogFormScreen())),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [BoxShadow(color: AppColors.accent.withAlpha(80), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.add, color: AppColors.surface, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 17, color: AppColors.muted),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.muted),
                maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String id, String label, Color activeColor, Color activeBg, Color activeText) {
    final active = _filter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            border: Border.all(color: active ? activeColor : AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? activeText : AppColors.muted,
            ),
          ),
        ),
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
