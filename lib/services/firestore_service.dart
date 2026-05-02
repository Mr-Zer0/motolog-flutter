import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Bike ── bike/default
  static Future<Bike?> fetchBike() async {
    final doc = await _db.doc('bike/default').get();
    if (!doc.exists) return null;
    final d = doc.data()!;
    return Bike(
      name: (d['name'] ?? '').toString(),
      brand: (d['brand'] ?? '').toString(),
      model: (d['model'] ?? '').toString(),
      year: d['year'] != null ? d['year'].toString() : '',
      color: (d['color'] ?? '').toString(),
      engineType: (d['engine_type'] ?? '').toString(),
      plate: (d['plate_number'] ?? '').toString(),
      vin: (d['vin'] ?? '').toString(),
      currentOdometer: d['current_odometer'] != null
          ? (d['current_odometer'] as num).toInt()
          : null,
      buyingDate: d['buying_date'] != null
          ? DateTime.tryParse(d['buying_date'].toString())
          : null,
    );
  }

  static Future<void> saveBike(Bike bike) async {
    await _db.doc('bike/default').set({
      'name': bike.name,
      'brand': bike.brand,
      'model': bike.model,
      'year': bike.year.isNotEmpty ? int.tryParse(bike.year) : null,
      'color': bike.color,
      'engine_type': bike.engineType.isNotEmpty ? bike.engineType : null,
      'plate_number': bike.plate,
      'vin': bike.vin,
      'current_odometer': bike.currentOdometer,
      'buying_date': bike.buyingDate != null ? _dateFormat.format(bike.buyingDate!) : null,
    }, SetOptions(merge: true));
  }

  // ── Log Entries ── logEntries/{auto-id}
  static CollectionReference<Map<String, dynamic>> get _logsRef =>
      _db.collection('logEntries');

  static DocumentReference<Map<String, dynamic>> get newLogRef => _logsRef.doc();

  static Future<List<LogEntry>> fetchLogs() async {
    final snap = await _logsRef.orderBy('date', descending: true).get();
    return snap.docs.map(_docToLog).toList();
  }

  static LogEntry _docToLog(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return LogEntry(
      id: doc.id.hashCode,
      firestoreId: doc.id,
      type: (d['type'] ?? 'other').toString(),
      title: (d['title'] ?? '').toString(),
      date: DateTime.tryParse((d['date'] ?? '').toString()) ?? DateTime.now(),
      odometer: d['odometer'] != null ? (d['odometer'] as num).toInt() : 0,
      cost: d['cost'] != null ? (d['cost'] as num).toDouble() : 0.0,
      description: (d['description'] ?? '').toString(),
      attachmentUrl: d['attachment_url'] as String?,
    );
  }

  static Future<void> saveLog(String docId, LogEntry log, {required bool isNew}) async {
    final data = <String, dynamic>{
      'type': log.type,
      'title': log.title,
      'date': _dateFormat.format(log.date),
      'odometer': log.odometer > 0 ? log.odometer : null,
      'cost': log.cost > 0 ? log.cost : null,
      'description': log.description.isNotEmpty ? log.description : null,
      'attachment_url': log.attachmentUrl,
    };
    if (isNew) {
      data['created_at'] = DateTime.now().toUtc().toIso8601String();
      await _logsRef.doc(docId).set(data);
    } else {
      await _logsRef.doc(docId).set(data, SetOptions(merge: true));
    }
  }

  static Future<void> deleteLog(String firestoreId) async {
    await _logsRef.doc(firestoreId).delete();
  }
}
