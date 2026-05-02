import 'package:flutter/foundation.dart';
import 'models.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

class AppState extends ChangeNotifier {
  List<LogEntry> _logs = [];
  Bike _bike = const Bike(name: '', year: '', plate: '', color: '');
  bool _loading = true;

  List<LogEntry> get logs => List.unmodifiable(_logs);
  Bike get bike => _bike;
  bool get loading => _loading;

  int get currentOdometer => _bike.currentOdometer ?? 0;
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
      FirestoreService.fetchLogs(),
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

  // attachmentPending: local file path to upload, remote URL to keep, or null for no attachment
  Future<void> saveLog(LogEntry log, String? attachmentPending) async {
    final docId = log.firestoreId ?? FirestoreService.newLogRef.id;
    final isNew = log.firestoreId == null;

    String? finalUrl;
    if (attachmentPending != null) {
      if (StorageService.isRemote(attachmentPending)) {
        finalUrl = attachmentPending;
      } else {
        finalUrl = await StorageService.uploadAttachment(attachmentPending);
      }
    }

    final saved = log.copyWith(
      firestoreId: docId,
      attachmentUrl: finalUrl,
      clearAttachmentUrl: finalUrl == null,
    );

    final idx = _logs.indexWhere((l) => l.id == log.id);
    if (idx >= 0) {
      _logs = List.from(_logs)..[idx] = saved;
    } else {
      _logs = [saved, ..._logs];
      _logs.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();

    await FirestoreService.saveLog(docId, saved, isNew: isNew);
  }

  Future<void> deleteLog(LogEntry log) async {
    _logs = _logs.where((l) => l.id != log.id).toList();
    notifyListeners();

    if (log.firestoreId != null) {
      await FirestoreService.deleteLog(log.firestoreId!);
      if (log.attachmentUrl != null) {
        StorageService.deleteAttachment(log.attachmentUrl!);
      }
    }
  }

  Future<void> updateBike(Bike bike) async {
    _bike = bike;
    notifyListeners();
    await FirestoreService.saveBike(bike);
  }

  String buildCsv() {
    final rows = ['Date,Type,Odometer (km),Cost (THB),Description'];
    for (final l in _logs) {
      final t = logTypeById(l.type).label;
      final desc = l.description.replaceAll(',', ';').replaceAll('\n', ' ');
      final d = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
      rows.add('$d,$t,${l.odometer},${l.cost.toStringAsFixed(2)},"$desc"');
    }
    return rows.join('\n');
  }
}
