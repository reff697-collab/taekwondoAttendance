import 'attendance_entry_model.dart';
import '../core/constants/app_constants.dart';

class AttendanceModel {
  final String id; // Format: YYYY-MM-DD_{scheduleId}
  final String scheduleId;
  final String sessionName;
  final DateTime date;
  final Map<String, AttendanceEntryModel> records; // key: studentId
  final String? coachId;
  final String? coachName;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.scheduleId,
    required this.sessionName,
    required this.date,
    required this.records,
    this.coachId,
    this.coachName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalStudents => records.length;
  
  int get totalHadir =>
      records.values.where((r) => r.status == AttendanceStatus.hadir).length;
      
  int get totalIzin =>
      records.values.where((r) => r.status == AttendanceStatus.izin).length;
      
  int get totalAlfa =>
      records.values.where((r) => r.status == AttendanceStatus.alfa).length;

  int get totalNotPresent => totalIzin + totalAlfa;

  double get attendancePercentage =>
      totalStudents > 0 ? (totalHadir / totalStudents) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'sessionName': sessionName,
      'date': date.toIso8601String(),
      'records': records.map((key, value) => MapEntry(key, value.toMap())),
      'coachId': coachId,
      'coachName': coachName,
      'createdAt': createdAt.toIso8601String(),
      'totalStudents': totalStudents,
      'totalHadir': totalHadir,
      'totalIzin': totalIzin,
      'totalAlfa': totalAlfa,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, AttendanceEntryModel> parsedRecords = {};
    if (map['records'] is Map) {
      final recMap = map['records'] as Map;
      recMap.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsedRecords[key.toString()] = AttendanceEntryModel.fromMap(val);
        } else if (val is Map) {
          parsedRecords[key.toString()] =
              AttendanceEntryModel.fromMap(Map<String, dynamic>.from(val));
        }
      });
    }

    DateTime parsedDate = DateTime.now();
    try {
      if (map['date'] is String) {
        parsedDate = DateTime.parse(map['date']);
      }
    } catch (_) {}

    DateTime parsedCreatedAt = DateTime.now();
    try {
      if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.parse(map['createdAt']);
      }
    } catch (_) {}

    return AttendanceModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      scheduleId: map['scheduleId'] ?? '',
      sessionName: map['sessionName'] ?? '',
      date: parsedDate,
      records: parsedRecords,
      coachId: map['coachId'],
      coachName: map['coachName'],
      createdAt: parsedCreatedAt,
    );
  }
}

