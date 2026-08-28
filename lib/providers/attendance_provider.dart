import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../models/attendance_entry_model.dart';
import '../models/student_model.dart';
import '../models/schedule_model.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';

class StudentMonthlyStat {
  final StudentModel student;
  final int totalSessions;
  final int hadirCount;
  final int izinCount;
  final int alfaCount;

  StudentMonthlyStat({
    required this.student,
    required this.totalSessions,
    required this.hadirCount,
    required this.izinCount,
    required this.alfaCount,
  });

  int get absentCount => izinCount + alfaCount;

  double get percentage =>
      totalSessions > 0 ? (hadirCount / totalSessions) * 100 : 0.0;
}

class AttendanceProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<AttendanceModel> _allAttendances = [];
  bool _isLoading = false;

  // Active Session State
  ScheduleModel? _currentSchedule;
  DateTime _currentSessionDate = DateTime.now();
  Map<String, AttendanceEntryModel> _currentRecords = {};
  bool _isSessionActive = false;

  // Recap Filter State
  DateTime _selectedRecapMonth = DateTime.now();

  AttendanceProvider(this._storageService) {
    loadAttendances();
  }

  List<AttendanceModel> get allAttendances => _allAttendances;
  bool get isLoading => _isLoading;

  ScheduleModel? get currentSchedule => _currentSchedule;
  DateTime get currentSessionDate => _currentSessionDate;
  Map<String, AttendanceEntryModel> get currentRecords => _currentRecords;
  bool get isSessionActive => _isSessionActive;

  DateTime get selectedRecapMonth => _selectedRecapMonth;

  // Counters for active session
  int get activeHadirCount => _currentRecords.values
      .where((r) => r.status == AttendanceStatus.hadir)
      .length;

  int get activeIzinCount => _currentRecords.values
      .where((r) => r.status == AttendanceStatus.izin)
      .length;

  int get activeAlfaCount => _currentRecords.values
      .where((r) => r.status == AttendanceStatus.alfa)
      .length;

  int get activeUnselectedCount => _currentRecords.values
      .where((r) => r.status == AttendanceStatus.unselected)
      .length;

  int get activeTotalStudents => _currentRecords.length;

  Future<void> loadAttendances() async {
    _isLoading = true;
    notifyListeners();

    _allAttendances = await _storageService.getAttendances();
    _isLoading = false;
    notifyListeners();
  }

  // --- ACTIVE SESSION WORKFLOW ---
  void startNewSession({
    required ScheduleModel schedule,
    required List<StudentModel> students,
    DateTime? date,
  }) {
    _currentSchedule = schedule;
    _currentSessionDate = date ?? DateTime.now();
    _currentRecords = {};

    // Check if an existing session exists for this date and schedule
    final dateStr =
        '${_currentSessionDate.year}-${_currentSessionDate.month.toString().padLeft(2, '0')}-${_currentSessionDate.day.toString().padLeft(2, '0')}';
    final existingId = '${dateStr}_${schedule.id}';
    final existingSession =
        _allAttendances.where((a) => a.id == existingId).firstOrNull;

    if (existingSession != null) {
      // Load existing session records
      _currentRecords = Map.from(existingSession.records);
      // Add any new students that were not in that session yet
      for (var s in students) {
        if (!_currentRecords.containsKey(s.id)) {
          _currentRecords[s.id] = AttendanceEntryModel(
            studentId: s.id,
            studentName: s.name,
            beltRank: s.beltRank,
            status: AttendanceStatus.unselected,
          );
        }
      }
    } else {
      // Initialize with unselected (or default)
      for (var s in students) {
        _currentRecords[s.id] = AttendanceEntryModel(
          studentId: s.id,
          studentName: s.name,
          beltRank: s.beltRank,
          status: AttendanceStatus.unselected,
        );
      }
    }

    _isSessionActive = true;
    notifyListeners();
  }

  void setStudentStatus(String studentId, AttendanceStatus status) {
    if (_currentRecords.containsKey(studentId)) {
      _currentRecords[studentId] =
          _currentRecords[studentId]!.copyWith(status: status);
      notifyListeners();
    }
  }

  void setStudentNote(String studentId, String note) {
    if (_currentRecords.containsKey(studentId)) {
      _currentRecords[studentId] = _currentRecords[studentId]!.copyWith(
        note: note.trim().isEmpty ? null : note.trim(),
      );
      notifyListeners();
    }
  }

  void markAllPresent() {
    _currentRecords.forEach((key, val) {
      _currentRecords[key] = val.copyWith(status: AttendanceStatus.hadir);
    });
    notifyListeners();
  }

  Future<void> saveCurrentSession(String coachName) async {
    if (_currentSchedule == null) return;

    final dateStr =
        '${_currentSessionDate.year}-${_currentSessionDate.month.toString().padLeft(2, '0')}-${_currentSessionDate.day.toString().padLeft(2, '0')}';
    final sessionId = '${dateStr}_${_currentSchedule!.id}';

    final session = AttendanceModel(
      id: sessionId,
      scheduleId: _currentSchedule!.id,
      sessionName: _currentSchedule!.sessionName,
      date: _currentSessionDate,
      records: Map.from(_currentRecords),
      coachName: coachName,
    );

    final existingIndex = _allAttendances.indexWhere((a) => a.id == sessionId);
    if (existingIndex >= 0) {
      _allAttendances[existingIndex] = session;
    } else {
      _allAttendances.insert(0, session);
    }

    _isSessionActive = false;
    notifyListeners();

    await _storageService.saveAttendance(session);
  }

  // --- RECAP CALCULATIONS ---
  void setRecapMonth(DateTime month) {
    _selectedRecapMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedRecapMonth =
        DateTime(_selectedRecapMonth.year, _selectedRecapMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedRecapMonth =
        DateTime(_selectedRecapMonth.year, _selectedRecapMonth.month + 1, 1);
    notifyListeners();
  }

  List<AttendanceModel> get monthlyAttendances {
    return _allAttendances.where((att) {
      return att.date.year == _selectedRecapMonth.year &&
          att.date.month == _selectedRecapMonth.month;
    }).toList();
  }

  int get totalMonthlySessions => monthlyAttendances.length;

  double get averageMonthlyAttendancePercentage {
    final list = monthlyAttendances;
    if (list.isEmpty) return 0.0;
    final sum = list.fold<double>(0.0, (acc, item) => acc + item.attendancePercentage);
    return sum / list.length;
  }

  List<StudentMonthlyStat> getStudentMonthlyStats(List<StudentModel> students) {
    final sessions = monthlyAttendances;
    final totalSes = sessions.length;

    return students.map((student) {
      int hadir = 0;
      int izin = 0;
      int alfa = 0;

      for (var sess in sessions) {
        final record = sess.records[student.id];
        if (record != null) {
          if (record.status == AttendanceStatus.hadir) {
            hadir++;
          } else if (record.status == AttendanceStatus.izin) {
            izin++;
          } else if (record.status == AttendanceStatus.alfa) {
            alfa++;
          }
        }
      }

      return StudentMonthlyStat(
        student: student,
        totalSessions: totalSes,
        hadirCount: hadir,
        izinCount: izin,
        alfaCount: alfa,
      );
    }).toList();
  }

  int get lowAttendanceCount {
    // Number of students with < 50% attendance
    final stats = getStudentMonthlyStats([]);
    return stats.where((s) => s.totalSessions > 0 && s.percentage < 50.0).length;
  }
}

