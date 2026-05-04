import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class AppState extends ChangeNotifier {
  List<LogEntry> _logs = [];
  Bike _bike = const Bike(name: '', year: '', plate: '', color: '');
  bool _loading = true;
  DateTime? _lastServerSync;

  static const _serverSyncTtl = Duration(minutes: 30);

  List<LogEntry> get logs => List.unmodifiable(_logs);
  Bike get bike => _bike;
  bool get loading => _loading;

  int get currentOdometer => _bike.currentOdometer ?? 0;
  double get totalCost => _logs.fold(0.0, (s, l) => s + l.cost);

  List<LogEntry> filteredLogs(String? typeFilter) {
    if (typeFilter == null || typeFilter == 'all') return _logs;
    return _logs.where((l) => l.type == typeFilter).toList();
  }

  Future<void> load({bool forceSync = false}) async {
    _loading = true;
    notifyListeners();

    final needsSync = forceSync ||
        _lastServerSync == null ||
        DateTime.now().difference(_lastServerSync!) > _serverSyncTtl;

    final source = needsSync ? Source.serverAndCache : Source.cache;

    final results = await Future.wait([
      FirestoreService.fetchBike(source: source),
      FirestoreService.fetchLogs(source: source),
    ]);

    _bike = (results[0] as Bike?) ??
        const Bike(name: 'My Bike', year: '', plate: '', color: '');
    _logs = results[1] as List<LogEntry>;
    _loading = false;
    if (needsSync) _lastServerSync = DateTime.now();
    notifyListeners();
  }

  void clear() {
    _logs = [];
    _bike = const Bike(name: '', year: '', plate: '', color: '');
    _loading = true;
    notifyListeners();
  }

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
    final rows = ['Date,Type,Odometer (km),Cost (THB),Title,Description'];
    for (final l in _logs) {
      final t = logTypeById(l.type).label;
      final title = _csvCell(l.title);
      final desc = _csvCell(l.description);
      final d = _dateFormat.format(l.date);
      rows.add('$d,$t,${l.odometer},${l.cost.toStringAsFixed(2)},"$title","$desc"');
    }
    return rows.join('\n');
  }

  static String _csvCell(String value) {
    var v = value.replaceAll('"', '""').replaceAll('\n', ' ');
    // Neutralise formula injection (Excel/Sheets execute cells starting with = + @ - |)
    if (v.isNotEmpty && '=+@-|'.contains(v[0])) v = "'$v";
    return v;
  }
}
