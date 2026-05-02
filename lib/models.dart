import 'package:flutter/material.dart';

class LogType {
  final String id;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const LogType({
    required this.id,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

const List<LogType> logTypes = [
  LogType(id: 'maintenance',  label: 'Maintenance',  color: Color(0xFF007F9E), bgColor: Color(0x1A007F9E), icon: Icons.build_outlined),
  LogType(id: 'modification', label: 'Modification', color: Color(0xFF7B4DB8), bgColor: Color(0x1A7B4DB8), icon: Icons.tune),
  LogType(id: 'repair',       label: 'Repair',       color: Color(0xFFC03C10), bgColor: Color(0x1AC03C10), icon: Icons.handyman_outlined),
  LogType(id: 'fuel',         label: 'Fuel',         color: Color(0xFFA06600), bgColor: Color(0x1AA06600), icon: Icons.local_gas_station_outlined),
  LogType(id: 'inspection',   label: 'Inspection',   color: Color(0xFF268038), bgColor: Color(0x1A268038), icon: Icons.search),
  LogType(id: 'cleaning',     label: 'Cleaning',     color: Color(0xFF2B62BE), bgColor: Color(0x1A2B62BE), icon: Icons.cleaning_services_outlined),
  LogType(id: 'other',        label: 'Other',        color: Color(0xFF887500), bgColor: Color(0x1A887500), icon: Icons.help_outline),
];

LogType logTypeById(String id) =>
    logTypes.firstWhere((t) => t.id == id, orElse: () => logTypes.last);

class LogEntry {
  final int id;
  final String? firestoreId;
  final String type;
  final String title;
  final DateTime date;
  final int odometer;
  final double cost;
  final String note;
  final List<String> images;

  const LogEntry({
    required this.id,
    this.firestoreId,
    required this.type,
    required this.title,
    required this.date,
    required this.odometer,
    required this.cost,
    required this.note,
    required this.images,
  });

  LogEntry copyWith({
    int? id,
    String? firestoreId,
    String? type,
    String? title,
    DateTime? date,
    int? odometer,
    double? cost,
    String? note,
    List<String>? images,
  }) {
    return LogEntry(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      note: note ?? this.note,
      images: images ?? this.images,
    );
  }
}

class Bike {
  final String name;
  final String year;
  final String plate;
  final String color;
  final String vin;
  final DateTime? buyingDate;
  final String engineType;

  const Bike({
    required this.name,
    required this.year,
    required this.plate,
    required this.color,
    this.vin = '',
    this.buyingDate,
    this.engineType = '',
  });

  Bike copyWith({
    String? name,
    String? year,
    String? plate,
    String? color,
    String? vin,
    DateTime? buyingDate,
    bool clearBuyingDate = false,
    String? engineType,
  }) {
    return Bike(
      name: name ?? this.name,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      buyingDate: clearBuyingDate ? null : (buyingDate ?? this.buyingDate),
      engineType: engineType ?? this.engineType,
    );
  }
}
