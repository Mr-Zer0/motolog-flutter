import 'package:flutter/foundation.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  List<LogEntry> _logs = [
    LogEntry(id: 1,  type: 'fuel',         title: 'Full tank',           date: DateTime(2026, 4, 20), odometer: 18420, cost: 18.60, note: '12.4L',                              images: []),
    LogEntry(id: 2,  type: 'maintenance',  title: 'Oil & filter change', date: DateTime(2026, 4, 10), odometer: 18200, cost: 42.00, note: 'Motul 10W-40',                       images: []),
    LogEntry(id: 3,  type: 'cleaning',     title: 'Full detail wash',    date: DateTime(2026, 4, 5),  odometer: 18100, cost: 12.00, note: '',                                   images: []),
    LogEntry(id: 4,  type: 'fuel',         title: 'Full tank',           date: DateTime(2026, 3, 28), odometer: 17980, cost: 17.70, note: '11.8L',                              images: []),
    LogEntry(id: 5,  type: 'inspection',   title: 'Pre-trip check',      date: DateTime(2026, 3, 15), odometer: 17800, cost: 0,     note: 'Chain, brakes, tire pressure',      images: []),
    LogEntry(id: 6,  type: 'repair',       title: 'Front brake pads',    date: DateTime(2026, 3, 8),  odometer: 17750, cost: 38.00, note: 'Replaced worn front pads',          images: []),
    LogEntry(id: 7,  type: 'fuel',         title: 'Full tank',           date: DateTime(2026, 3, 2),  odometer: 17600, cost: 19.65, note: '13.1L',                              images: []),
    LogEntry(id: 8,  type: 'modification', title: 'Rear tire upgrade',   date: DateTime(2026, 2, 20), odometer: 17400, cost: 120.0, note: 'Michelin Pilot Street 2',           images: []),
    LogEntry(id: 9,  type: 'fuel',         title: 'Full tank',           date: DateTime(2026, 2, 14), odometer: 17200, cost: 18.00, note: '12.0L',                              images: []),
    LogEntry(id: 10, type: 'maintenance',  title: 'Annual service',      date: DateTime(2026, 2, 5),  odometer: 17100, cost: 65.00, note: 'Spark plug, air filter replaced',   images: []),
  ];

  Bike _bike = const Bike(name: 'Honda CB500F', year: '2021', plate: 'B 1234 XYZ', color: 'Matte Black');

  List<LogEntry> get logs => List.unmodifiable(_logs);
  Bike get bike => _bike;

  int get currentOdometer => _logs.fold(0, (m, l) => l.odometer > m ? l.odometer : m);
  double get totalCost => _logs.fold(0.0, (s, l) => s + l.cost);

  List<LogEntry> filteredLogs(String? typeFilter) {
    if (typeFilter == null || typeFilter == 'all') return _logs;
    return _logs.where((l) => l.type == typeFilter).toList();
  }

  void saveLog(LogEntry log) {
    final idx = _logs.indexWhere((l) => l.id == log.id);
    if (idx >= 0) {
      final updated = List<LogEntry>.from(_logs);
      updated[idx] = log;
      _logs = updated;
    } else {
      _logs = [log, ..._logs];
    }
    _logs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void deleteLog(int id) {
    _logs = _logs.where((l) => l.id != id).toList();
    notifyListeners();
  }

  void updateBike(Bike bike) {
    _bike = bike;
    notifyListeners();
  }

  String buildCsv() {
    final rows = ['Date,Type,Odometer (km),Cost,Notes'];
    for (final l in _logs) {
      final t = logTypeById(l.type).label;
      final note = l.note.replaceAll(',', ';').replaceAll('\n', ' ');
      final dateStr = '${l.date.year}-${l.date.month.toString().padLeft(2,'0')}-${l.date.day.toString().padLeft(2,'0')}';
      rows.add('$dateStr,$t,${l.odometer},${l.cost.toStringAsFixed(2)},"$note"');
    }
    return rows.join('\n');
  }
}
