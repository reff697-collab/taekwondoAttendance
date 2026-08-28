import '../core/constants/app_constants.dart';

class StudentModel {
  final String id;
  final String name;
  final BeltRank beltRank;
  final DateTime joinDate;
  final bool isActive;
  final String? phoneNumber;
  final String? notes;

  StudentModel({
    required this.id,
    required this.name,
    required this.beltRank,
    required this.joinDate,
    this.isActive = true,
    this.phoneNumber,
    this.notes,
  });

  StudentModel copyWith({
    String? id,
    String? name,
    BeltRank? beltRank,
    DateTime? joinDate,
    bool? isActive,
    String? phoneNumber,
    String? notes,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      beltRank: beltRank ?? this.beltRank,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'beltRank': beltRank.name,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'notes': notes,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    BeltRank parsedBelt = BeltRank.putih;
    try {
      parsedBelt = BeltRank.values.firstWhere(
        (b) => b.name == map['beltRank'],
        orElse: () => BeltRank.putih,
      );
    } catch (_) {}

    DateTime parsedDate = DateTime.now();
    try {
      if (map['joinDate'] is String) {
        parsedDate = DateTime.parse(map['joinDate']);
      }
    } catch (_) {}

    return StudentModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      name: map['name'] ?? '',
      beltRank: parsedBelt,
      joinDate: parsedDate,
      isActive: map['isActive'] ?? true,
      phoneNumber: map['phoneNumber'],
      notes: map['notes'],
    );
  }
}

