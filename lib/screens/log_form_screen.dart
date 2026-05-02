import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/app_field.dart';
import '../widgets/image_uploader.dart';
import '../widgets/log_type_grid.dart';
import '../widgets/primary_button.dart';
import '../widgets/success_overlay.dart';

class LogFormScreen extends StatefulWidget {
  final LogEntry? initial;
  const LogFormScreen({super.key, this.initial});

  @override
  State<LogFormScreen> createState() => _LogFormScreenState();
}

class _LogFormScreenState extends State<LogFormScreen> {
  late String? _type;
  late TextEditingController _titleCtrl;
  late DateTime _date;
  late TextEditingController _odoCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _noteCtrl;
  late List<String> _images;
  bool _saved = false;
  bool _confirmDelete = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _type     = i?.type;
    _titleCtrl = TextEditingController(text: i?.title ?? '');
    _date     = i?.date ?? DateTime.now();
    _odoCtrl  = TextEditingController(text: i != null ? '${i.odometer}' : '');
    _costCtrl = TextEditingController(text: i != null && i.cost > 0 ? i.cost.toStringAsFixed(2) : '');
    _noteCtrl = TextEditingController(text: i?.note ?? '');
    _images   = List.from(i?.images ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _odoCtrl.dispose();
    _costCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(AppState state) async {
    setState(() => _saved = true);
    final odo = int.tryParse(_odoCtrl.text) ?? state.currentOdometer;
    final cost = double.tryParse(_costCtrl.text) ?? 0.0;
    final entry = LogEntry(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch,
      firestoreId: widget.initial?.firestoreId,
      type: _type!,
      title: _titleCtrl.text.trim(),
      date: _date,
      odometer: odo,
      cost: cost,
      note: _noteCtrl.text.trim(),
      images: const [],
    );
    await state.saveLog(entry, _images);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) Navigator.pop(context, entry);
  }

  Future<void> _delete(AppState state) async {
    await state.deleteLog(widget.initial!);
    if (mounted) Navigator.pop(context);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (_saved) {
          return Scaffold(
            body: SafeArea(child: SuccessOverlay(message: _isEdit ? 'Log updated' : 'Log saved')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
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
                                Text('Cancel',
                                    style: GoogleFonts.outfit(
                                        fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.accent)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _isEdit ? 'Edit Log' : 'New Log',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                          ),
                          if (_isEdit)
                            GestureDetector(
                              onTap: () => setState(() => _confirmDelete = true),
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline, size: 15, color: Color(0xFFC03C10)),
                                  const SizedBox(width: 4),
                                  Text('Delete',
                                      style: GoogleFonts.outfit(
                                          fontSize: 14, fontWeight: FontWeight.w500,
                                          color: const Color(0xFFC03C10))),
                                ],
                              ),
                            )
                          else
                            const SizedBox(width: 60),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                        children: [
                          // Type grid
                          AppField(
                            label: 'Log Type',
                            child: LogTypeGrid(
                              selectedType: _type,
                              onSelect: (id) => setState(() => _type = id),
                            ),
                          ),

                          AppField(
                            label: 'Title',
                            child: AppInput(controller: _titleCtrl, placeholder: 'e.g. Monthly oil change'),
                          ),

                          AppField(
                            label: 'Date',
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat('d MMM yyyy').format(_date),
                                  style: GoogleFonts.outfit(fontSize: 15, color: AppColors.text),
                                ),
                              ),
                            ),
                          ),

                          AppField(
                            label: 'Odometer (km)',
                            child: AppInput(
                              controller: _odoCtrl,
                              placeholder: '${state.currentOdometer}',
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          AppField(
                            label: 'Cost — optional',
                            child: AppInput(
                              controller: _costCtrl,
                              placeholder: '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),

                          AppField(
                            label: 'Notes — optional',
                            child: AppInput(
                              controller: _noteCtrl,
                              placeholder: 'Add details…',
                              maxLines: 3,
                            ),
                          ),

                          AppField(
                            label: 'Photos — optional',
                            child: ImageUploader(
                              images: _images,
                              onChange: (imgs) => setState(() => _images = imgs),
                            ),
                          ),

                          const SizedBox(height: 8),
                          PrimaryButton(
                            onPressed: _type != null ? () => _save(state) : null,
                            label: _isEdit ? 'Update Log' : 'Save Log',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Delete confirmation sheet
                if (_confirmDelete)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _confirmDelete = false),
                      child: Container(
                        color: Colors.black.withAlpha(76),
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Delete this log?',
                                    style: GoogleFonts.outfit(
                                        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
                                const SizedBox(height: 6),
                                Text('This action cannot be undone.',
                                    style: GoogleFonts.outfit(fontSize: 14, color: AppColors.muted)),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => _delete(state),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFC03C10),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: Text('Delete',
                                        style: GoogleFonts.outfit(
                                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => setState(() => _confirmDelete = false),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(color: AppColors.border, width: 1.5),
                                      ),
                                    ),
                                    child: Text('Cancel',
                                        style: GoogleFonts.outfit(
                                            fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
