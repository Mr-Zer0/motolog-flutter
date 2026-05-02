import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/app_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/success_overlay.dart';

class BikeScreen extends StatefulWidget {
  final Bike bike;
  const BikeScreen({super.key, required this.bike});

  @override
  State<BikeScreen> createState() => _BikeScreenState();
}

class _BikeScreenState extends State<BikeScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _plateCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _vinCtrl;
  late TextEditingController _currentOdoCtrl;
  late String _engineType;
  DateTime? _buyingDate;
  bool _saved = false;

  static const _engineTypes = ['ICE', 'EV', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _nameCtrl       = TextEditingController(text: widget.bike.name);
    _brandCtrl      = TextEditingController(text: widget.bike.brand);
    _modelCtrl      = TextEditingController(text: widget.bike.model);
    _yearCtrl       = TextEditingController(text: widget.bike.year);
    _plateCtrl      = TextEditingController(text: widget.bike.plate);
    _colorCtrl      = TextEditingController(text: widget.bike.color);
    _vinCtrl        = TextEditingController(text: widget.bike.vin);
    _currentOdoCtrl = TextEditingController(
        text: widget.bike.currentOdometer != null ? '${widget.bike.currentOdometer}' : '');
    _engineType  = widget.bike.engineType;
    _buyingDate  = widget.bike.buyingDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    _vinCtrl.dispose();
    _currentOdoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBuyingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _buyingDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _buyingDate = picked);
  }

  void _save(AppState state) {
    state.updateBike(Bike(
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      plate: _plateCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      vin: _vinCtrl.text.trim(),
      buyingDate: _buyingDate,
      engineType: _engineType,
      currentOdometer: int.tryParse(_currentOdoCtrl.text),
    ));
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (_saved) {
          return Scaffold(
            body: SafeArea(child: SuccessOverlay(message: 'Bike updated')),
          );
        }

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
                            Text('Cancel',
                                style: GoogleFonts.outfit(
                                    fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.accent)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text('Bike Info',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                    children: [
                      // Bike placeholder
                      Container(
                        width: double.infinity,
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.two_wheeler, size: 48, color: AppColors.subtle),
                      ),

                      AppField(
                        label: 'Bike Name',
                        child: AppInput(controller: _nameCtrl, placeholder: 'e.g. My Honda'),
                      ),
                      AppField(
                        label: 'Brand',
                        child: AppInput(controller: _brandCtrl, placeholder: 'e.g. Honda'),
                      ),
                      AppField(
                        label: 'Model',
                        child: AppInput(controller: _modelCtrl, placeholder: 'e.g. CB500F'),
                      ),
                      AppField(
                        label: 'Year',
                        child: AppInput(controller: _yearCtrl, placeholder: 'e.g. 2021', keyboardType: TextInputType.number),
                      ),
                      AppField(
                        label: 'Plate Number',
                        child: AppInput(controller: _plateCtrl, placeholder: 'e.g. กข 1234'),
                      ),
                      AppField(
                        label: 'Color',
                        child: AppInput(controller: _colorCtrl, placeholder: 'e.g. Matte Black'),
                      ),
                      AppField(
                        label: 'VIN',
                        child: AppInput(controller: _vinCtrl, placeholder: 'e.g. 1HGBH41JXMN109186'),
                      ),
                      AppField(
                        label: 'Current Odometer (km)',
                        child: AppInput(
                          controller: _currentOdoCtrl,
                          placeholder: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      AppField(
                        label: 'Engine Type',
                        child: Row(
                          children: _engineTypes.map((type) {
                            final selected = _engineType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _engineType = type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.accentBg : AppColors.surface,
                                    border: Border.all(
                                      color: selected ? AppColors.accent : AppColors.border,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    type,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? AppColors.accentText : AppColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      AppField(
                        label: 'Buying Date',
                        child: GestureDetector(
                          onTap: _pickBuyingDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _buyingDate != null
                                  ? DateFormat('d MMM yyyy').format(_buyingDate!)
                                  : 'Select date',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: _buyingDate != null ? AppColors.text : AppColors.subtle,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      PrimaryButton(
                        onPressed: () => _save(state),
                        label: 'Save Changes',
                      ),
                    ],
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
