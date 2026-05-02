import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static bool isRemote(String path) => path.startsWith('http');

  static Future<String> uploadAttachment(String localPath) async {
    final file = File(localPath);
    final fileName = localPath.split('/').last;
    final ref = _storage.ref('attachments/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  static Future<void> deleteAttachment(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}
