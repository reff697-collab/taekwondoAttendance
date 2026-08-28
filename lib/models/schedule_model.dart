class ScheduleModel {
  final String id;
  final String sessionName;
  final String day; // e.g. "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"
  final int dayOfWeek; // 1 = Monday ... 7 = Sunday
  final String startTime; // "16:00"
  final String endTime; // "18:00"
  final String? category; // "Reguler", "Kadet Prestasi", "Poomsae", etc.

  ScheduleModel({
    required this.id,
    required this.sessionName,
    required this.day,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.category,
  });

  ScheduleModel copyWith({
    String? id,
    String? sessionName,
    String? day,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? category,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      sessionName: sessionName ?? this.sessionName,
      day: day ?? this.day,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionName': sessionName,
      'day': day,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ScheduleModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      sessionName: map['sessionName'] ?? '',
      day: map['day'] ?? 'Senin',
      dayOfWeek: map['dayOfWeek'] ?? 1,
      startTime: map['startTime'] ?? '16:00',
      endTime: map['endTime'] ?? '18:00',
      category: map['category'],
    );
  }
}

