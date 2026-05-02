import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Bike ── /bike/default
  static Future<Bike?> fetchBike() async {
    final doc = await _db.doc('bike/default').get();
    if (!doc.exists) return null;
    final d = doc.data()!;
    return Bike(
      name: d['name'] ?? '',
      year: d['year'] ?? '',
      plate: d['plate'] ?? '',
      color: d['color'] ?? '',
      vin: d['vin'] ?? '',
      engineType: d['engineType'] ?? '',
      buyingDate: d['buyingDate'] != null
          ? (d['buyingDate'] as Timestamp).toDate()
          : null,
    );
  }

  static Future<void> saveBike(Bike bike) async {
    await _db.doc('bike/default').set({
      'name': bike.name,
      'year': bike.year,
      'plate': bike.plate,
      'color': bike.color,
      'vin': bike.vin,
      'engineType': bike.engineType,
      'buyingDate': bike.buyingDate != null
          ? Timestamp.fromDate(bike.buyingDate!)
          : null,
    }, SetOptions(merge: true));
  }

  // ── Log Entries ── /logEntries/{uid}/entries/{logId}
  static CollectionReference<Map<String, dynamic>> _logsRef(String uid) =>
      _db.collection('logEntries').doc(uid).collection('entries');

  static DocumentReference<Map<String, dynamic>> newLogRef(String uid) =>
      _logsRef(uid).doc();

  static Future<List<LogEntry>> fetchLogs(String uid) async {
    final snap = await _logsRef(uid).orderBy('date', descending: true).get();
    return snap.docs.map(_docToLog).toList();
  }

  static LogEntry _docToLog(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return LogEntry(
      id: doc.id.hashCode,
      firestoreId: doc.id,
      type: d['type'] ?? 'other',
      title: d['title'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      odometer: (d['odometer'] ?? 0) as int,
      cost: (d['cost'] ?? 0).toDouble(),
      note: d['note'] ?? '',
      images: List<String>.from(d['images'] ?? []),
    );
  }

  static Future<void> saveLog(
      String uid, String docId, LogEntry log) async {
    await _logsRef(uid).doc(docId).set({
      'type': log.type,
      'title': log.title,
      'date': Timestamp.fromDate(log.date),
      'odometer': log.odometer,
      'cost': log.cost,
      'note': log.note,
      'images': log.images,
    });
  }

  static Future<void> deleteLog(String uid, String firestoreId) async {
    await _logsRef(uid).doc(firestoreId).delete();
  }
}
