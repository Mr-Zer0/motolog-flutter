import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'};
  static const _storageDomain = 'firebasestorage';

  static bool isRemote(String path) => path.startsWith('http');

  static bool _isOwnStorageUrl(String url) =>
      url.contains(_storageDomain);

  static Future<String> uploadAttachment(String localPath) async {
    final file = File(localPath);

    final rawName = localPath.split('/').last;
    final sanitizedName = rawName.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final ext = sanitizedName.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      throw Exception('Unsupported file type: $ext');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    final ref = _storage.ref('attachments/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  static Future<void> deleteAttachment(String url) async {
    if (!_isOwnStorageUrl(url)) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}
