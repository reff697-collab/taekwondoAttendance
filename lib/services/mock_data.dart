import '../models/student_model.dart';
import '../models/schedule_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_entry_model.dart';
import '../core/constants/app_constants.dart';

class MockData {
  static List<StudentModel> get initialStudents => [
        StudentModel(
          id: 'std_01',
          name: 'Budi Santoso',
          beltRank: BeltRank.biru,
          joinDate: DateTime(2025, 1, 15),
          phoneNumber: '081234567890',
        ),
        StudentModel(
          id: 'std_02',
          name: 'Santi Wijaya',
          beltRank: BeltRank.merah,
          joinDate: DateTime(2024, 6, 10),
          phoneNumber: '081298765432',
        ),
        StudentModel(
          id: 'std_03',
          name: 'Ahmad Putra',
          beltRank: BeltRank.hitamDan1,
          joinDate: DateTime(2023, 2, 20),
          phoneNumber: '085611223344',
        ),
        StudentModel(
          id: 'std_04',
          name: 'Andi Saputra',
          beltRank: BeltRank.kuning,
          joinDate: DateTime(2025, 8, 1),
          phoneNumber: '087811998877',
        ),
        StudentModel(
          id: 'std_05',
          name: 'Dewi Lestari',
          beltRank: BeltRank.hijau,
          joinDate: DateTime(2025, 3, 12),
          phoneNumber: '081344556677',
        ),
        StudentModel(
          id: 'std_06',
          name: 'Rizky Pradana',
          beltRank: BeltRank.hitamDan1,
          joinDate: DateTime(2022, 11, 5),
          phoneNumber: '081900112233',
        ),
        StudentModel(
          id: 'std_07',
          name: 'Siti Aminah',
          beltRank: BeltRank.biruStrip,
          joinDate: DateTime(2024, 9, 18),
          phoneNumber: '085233445566',
        ),
        StudentModel(
          id: 'std_08',
          name: 'Fajar Nugraha',
          beltRank: BeltRank.kuningStrip,
          joinDate: DateTime(2025, 5, 22),
          phoneNumber: '089612345678',
        ),
        StudentModel(
          id: 'std_09',
          name: 'Dimas Pratama',
          beltRank: BeltRank.hijauStrip,
          joinDate: DateTime(2024, 12, 1),
          phoneNumber: '081255667788',
        ),
        StudentModel(
          id: 'std_10',
          name: 'Clarissa Maharani',
          beltRank: BeltRank.merahStrip,
          joinDate: DateTime(2023, 8, 14),
          phoneNumber: '085799887766',
        ),
        StudentModel(
          id: 'std_11',
          name: 'Kevin Wijaya',
          beltRank: BeltRank.putih,
          joinDate: DateTime(2026, 1, 10),
          phoneNumber: '081399881122',
        ),
        StudentModel(
          id: 'std_12',
          name: 'Nabila Syakieb',
          beltRank: BeltRank.putih,
          joinDate: DateTime(2026, 2, 5),
          phoneNumber: '081277665544',
        ),
      ];

  static List<ScheduleModel> get initialSchedules => [
        ScheduleModel(
          id: 'sch_senin',
          sessionName: 'Poomsae & Dasar',
          day: 'Senin',
          dayOfWeek: DateTime.monday,
          startTime: '16:00',
          endTime: '18:00',
          category: 'Reguler',
        ),
        ScheduleModel(
          id: 'sch_rabu',
          sessionName: 'Kyorugi & Fisik',
          day: 'Rabu',
          dayOfWeek: DateTime.wednesday,
          startTime: '16:00',
          endTime: '18:00',
          category: 'Reguler',
        ),
        ScheduleModel(
          id: 'sch_jumat',
          sessionName: 'Kadet Prestasi & Sparring',
          day: 'Jumat',
          dayOfWeek: DateTime.friday,
          startTime: '15:30',
          endTime: '18:00',
          category: 'Prestasi',
        ),
        ScheduleModel(
          id: 'sch_sabtu',
          sessionName: 'Kyorugi Training & Ujian',
          day: 'Sabtu',
          dayOfWeek: DateTime.saturday,
          startTime: '16:00',
          endTime: '18:00',
          category: 'Reguler',
        ),
        ScheduleModel(
          id: 'sch_minggu',
          sessionName: 'Latihan Pagi & Peregangan',
          day: 'Minggu',
          dayOfWeek: DateTime.sunday,
          startTime: '07:00',
          endTime: '09:00',
          category: 'Umum',
        ),
      ];

  static List<AttendanceModel> generateInitialAttendances(
      List<StudentModel> students, List<ScheduleModel> schedules) {
    final now = DateTime.now();
    final List<AttendanceModel> list = [];

    // Generate past 6 sessions this month for realistic recap calculations
    for (int i = 1; i <= 6; i++) {
      final date = now.subtract(Duration(days: i * 3));
      final schedule = schedules[(i - 1) % schedules.length];

      final Map<String, AttendanceEntryModel> records = {};
      for (var std in students) {
        // Pseudo random realistic status
        final hash = (std.id.hashCode + i) % 10;
        AttendanceStatus status;
        String? note;

        if (hash < 7) {
          status = AttendanceStatus.hadir;
        } else if (hash < 9) {
          status = AttendanceStatus.izin;
          note = hash == 7 ? 'Sakit flu' : 'Ujian sekolah';
        } else {
          status = AttendanceStatus.alfa;
        }

        records[std.id] = AttendanceEntryModel(
          studentId: std.id,
          studentName: std.name,
          beltRank: std.beltRank,
          status: status,
          note: note,
        );
      }

      list.add(
        AttendanceModel(
          id: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_${schedule.id}',
          scheduleId: schedule.id,
          sessionName: schedule.sessionName,
          date: date,
          records: records,
          coachName: 'Sabeum Nim',
        ),
      );
    }

    return list;
  }
}

