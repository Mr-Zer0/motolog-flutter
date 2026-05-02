import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static bool isRemote(String path) => path.startsWith('http');

  static Future<String> uploadImage(
      String uid, String logId, String localPath) async {
    final file = File(localPath);
    final fileName = localPath.split('/').last;
    final ref = _storage.ref('images/$uid/$logId/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  // Returns list with local paths replaced by remote URLs.
  static Future<List<String>> uploadPending(
      String uid, String logId, List<String> images) async {
    final result = <String>[];
    for (final img in images) {
      if (isRemote(img)) {
        result.add(img);
      } else {
        result.add(await uploadImage(uid, logId, img));
      }
    }
    return result;
  }

  static Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}
