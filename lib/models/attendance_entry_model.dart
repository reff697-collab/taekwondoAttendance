import '../core/constants/app_constants.dart';

class AttendanceEntryModel {
  final String studentId;
  final String studentName;
  final BeltRank beltRank;
  final AttendanceStatus status;
  final String? note;

  AttendanceEntryModel({
    required this.studentId,
    required this.studentName,
    required this.beltRank,
    this.status = AttendanceStatus.unselected,
    this.note,
  });

  AttendanceEntryModel copyWith({
    String? studentId,
    String? studentName,
    BeltRank? beltRank,
    AttendanceStatus? status,
    String? note,
  }) {
    return AttendanceEntryModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      beltRank: beltRank ?? this.beltRank,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'beltRank': beltRank.name,
      'status': status.name,
      'note': note,
    };
  }

  factory AttendanceEntryModel.fromMap(Map<String, dynamic> map) {
    BeltRank parsedBelt = BeltRank.putih;
    try {
      parsedBelt = BeltRank.values.firstWhere((b) => b.name == map['beltRank']);
    } catch (_) {}

    AttendanceStatus parsedStatus = AttendanceStatus.unselected;
    try {
      parsedStatus = AttendanceStatus.values.firstWhere((s) => s.name == map['status']);
    } catch (_) {}

    return AttendanceEntryModel(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      beltRank: parsedBelt,
      status: parsedStatus,
      note: map['note'],
    );
  }
}

