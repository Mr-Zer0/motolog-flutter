import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app_colors.dart';

class ImageUploader extends StatelessWidget {
  final List<String> images;
  final ValueChanged<List<String>> onChange;

  const ImageUploader({super.key, required this.images, required this.onChange});

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      onChange([...images, ...picked.map((x) => x.path)]);
    }
  }

  void _remove(int idx) {
    final updated = List<String>.from(images)..removeAt(idx);
    onChange(updated);
  }

  void _view(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImage(path: path),
        fullscreenDialog: true,
      ),
    );
  }

  static Widget _buildImage(String path, {double? width, double? height}) {
    const fit = BoxFit.cover;
    if (path.startsWith('http')) {
      return Image.network(path, width: width, height: height, fit: fit);
    }
    return Image.file(File(path), width: width, height: height, fit: fit);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images.asMap().entries.map((e) {
                return GestureDetector(
                  onTap: () => _view(context, e.value),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(e.value, width: 80, height: 80),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _remove(e.key),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 18, color: AppColors.subtle),
                const SizedBox(width: 8),
                Text(
                  'Add Photo',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  final String path;
  const _FullscreenImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(224),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: ImageUploader._buildImage(path),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
