import 'package:flutter/foundation.dart';
import 'models.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

class AppState extends ChangeNotifier {
  List<LogEntry> _logs = [];
  Bike _bike = const Bike(name: '', year: '', plate: '', color: '');
  bool _loading = true;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  Bike get bike => _bike;
  bool get loading => _loading;

  int get currentOdometer => _logs.fold(0, (m, l) => l.odometer > m ? l.odometer : m);
  double get totalCost => _logs.fold(0.0, (s, l) => s + l.cost);

  List<LogEntry> filteredLogs(String? typeFilter) {
    if (typeFilter == null || typeFilter == 'all') return _logs;
    return _logs.where((l) => l.type == typeFilter).toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final results = await Future.wait([
      FirestoreService.fetchBike(),
      FirestoreService.fetchLogs(AuthService.uid!),
    ]);

    _bike = (results[0] as Bike?) ??
        const Bike(name: 'My Bike', year: '', plate: '', color: '');
    _logs = results[1] as List<LogEntry>;
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _logs = [];
    _bike = const Bike(name: '', year: '', plate: '', color: '');
    _loading = true;
    notifyListeners();
  }

  Future<void> saveLog(LogEntry log, List<String> localImages) async {
    final uid = AuthService.uid!;

    // Determine Firestore doc ID (new or existing)
    final docId = log.firestoreId ?? FirestoreService.newLogRef(uid).id;

    // Upload any new local images, get back URLs
    final uploadedImages = await StorageService.uploadPending(uid, docId, localImages);
    final saved = log.copyWith(firestoreId: docId, images: uploadedImages);

    // Optimistic update
    final idx = _logs.indexWhere((l) => l.id == log.id);
    if (idx >= 0) {
      _logs = List.from(_logs)..[idx] = saved;
    } else {
      _logs = [saved, ..._logs];
      _logs.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();

    await FirestoreService.saveLog(uid, docId, saved);
  }

  Future<void> deleteLog(LogEntry log) async {
    final uid = AuthService.uid!;
    _logs = _logs.where((l) => l.id != log.id).toList();
    notifyListeners();

    if (log.firestoreId != null) {
      await FirestoreService.deleteLog(uid, log.firestoreId!);
      for (final img in log.images) {
        if (StorageService.isRemote(img)) StorageService.deleteImage(img);
      }
    }
  }

  Future<void> updateBike(Bike bike) async {
    _bike = bike;
    notifyListeners();
    await FirestoreService.saveBike(bike);
  }

  String buildCsv() {
    final rows = ['Date,Type,Odometer (km),Cost,Notes'];
    for (final l in _logs) {
      final t = logTypeById(l.type).label;
      final note = l.note.replaceAll(',', ';').replaceAll('\n', ' ');
      final d = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
      rows.add('$d,$t,${l.odometer},${l.cost.toStringAsFixed(2)},"$note"');
    }
    return rows.join('\n');
  }
}
