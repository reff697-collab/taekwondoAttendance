import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../models/schedule_model.dart';
import '../models/attendance_model.dart';
import 'mock_data.dart';
import 'firebase_service.dart';

class StorageService {
  static const String _keyStudents = 'gta_students_v1';
  static const String _keySchedules = 'gta_schedules_v1';
  static const String _keyAttendances = 'gta_attendances_v1';
  static const String _keyCoachName = 'gta_coach_name_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Seed initial mock data if empty
    if (!_prefs.containsKey(_keyStudents)) {
      final initialStds = MockData.initialStudents;
      await saveStudents(initialStds);
    }
    if (!_prefs.containsKey(_keySchedules)) {
      final initialSchs = MockData.initialSchedules;
      await saveSchedules(initialSchs);
    }
    if (!_prefs.containsKey(_keyAttendances)) {
      final stds = await getStudents();
      final schs = await getSchedules();
      final initialAtts = MockData.generateInitialAttendances(stds, schs);
      await saveAttendances(initialAtts);
    }
    if (!_prefs.containsKey(_keyCoachName)) {
      await _prefs.setString(_keyCoachName, 'Sabeum Nim');
    }
  }

  // Coach Name
  String getCoachName() {
    return _prefs.getString(_keyCoachName) ?? 'Sabeum Nim';
  }

  Future<void> setCoachName(String name) async {
    await _prefs.setString(_keyCoachName, name);
  }

  // --- STUDENTS ---
  Future<List<StudentModel>> getStudents() async {
    if (FirebaseService.isInitialized) {
      try {
        final onlineList = await FirebaseService.fetchStudents();
        if (onlineList.isNotEmpty) {
          await saveStudents(onlineList);
          return onlineList;
        }
      } catch (_) {}
    }

    final raw = _prefs.getString(_keyStudents);
    if (raw == null || raw.isEmpty) return MockData.initialStudents;
    final List decoded = jsonDecode(raw);
    return decoded
        .map((item) =>
            StudentModel.fromMap(Map<String, dynamic>.from(item), item['id'] ?? ''))
        .where((s) => s.isActive)
        .toList();
  }

  Future<void> saveStudents(List<StudentModel> students) async {
    final encoded = jsonEncode(students.map((s) => s.toMap()).toList());
    await _prefs.setString(_keyStudents, encoded);
  }

  Future<void> saveStudent(StudentModel student) async {
    final list = await getStudents();
    final index = list.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      list[index] = student;
    } else {
      list.add(student);
    }
    await saveStudents(list);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.saveStudent(student);
      } catch (_) {}
    }
  }

  Future<void> deleteStudent(String studentId) async {
    final list = await getStudents();
    final index = list.indexWhere((s) => s.id == studentId);
    if (index >= 0) {
      list[index] = list[index].copyWith(isActive: false);
      await saveStudents(list);
    }

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.deleteStudent(studentId);
      } catch (_) {}
    }
  }

  // --- SCHEDULES ---
  Future<List<ScheduleModel>> getSchedules() async {
    if (FirebaseService.isInitialized) {
      try {
        final onlineList = await FirebaseService.fetchSchedules();
        if (onlineList.isNotEmpty) {
          await saveSchedules(onlineList);
          return onlineList;
        }
      } catch (_) {}
    }

    final raw = _prefs.getString(_keySchedules);
    if (raw == null || raw.isEmpty) return MockData.initialSchedules;
    final List decoded = jsonDecode(raw);
    return decoded
        .map((item) =>
            ScheduleModel.fromMap(Map<String, dynamic>.from(item), item['id'] ?? ''))
        .toList();
  }

  Future<void> saveSchedules(List<ScheduleModel> schedules) async {
    final encoded = jsonEncode(schedules.map((s) => s.toMap()).toList());
    await _prefs.setString(_keySchedules, encoded);
  }

  Future<void> saveSchedule(ScheduleModel schedule) async {
    final list = await getSchedules();
    final index = list.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      list[index] = schedule;
    } else {
      list.add(schedule);
    }
    await saveSchedules(list);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.saveSchedule(schedule);
      } catch (_) {}
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final list = await getSchedules();
    list.removeWhere((s) => s.id == scheduleId);
    await saveSchedules(list);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.deleteSchedule(scheduleId);
      } catch (_) {}
    }
  }

  // --- ATTENDANCES ---
  Future<List<AttendanceModel>> getAttendances() async {
    if (FirebaseService.isInitialized) {
      try {
        final onlineList = await FirebaseService.fetchAttendances();
        if (onlineList.isNotEmpty) {
          await saveAttendances(onlineList);
          return onlineList;
        }
      } catch (_) {}
    }

    final raw = _prefs.getString(_keyAttendances);
    if (raw == null || raw.isEmpty) {
      final stds = await getStudents();
      final schs = await getSchedules();
      return MockData.generateInitialAttendances(stds, schs);
    }
    final List decoded = jsonDecode(raw);
    return decoded
        .map((item) =>
            AttendanceModel.fromMap(Map<String, dynamic>.from(item), item['id'] ?? ''))
        .toList();
  }

  Future<void> saveAttendances(List<AttendanceModel> attendances) async {
    final encoded = jsonEncode(attendances.map((a) => a.toMap()).toList());
    await _prefs.setString(_keyAttendances, encoded);
  }

  Future<void> saveAttendance(AttendanceModel attendance) async {
    final list = await getAttendances();
    final index = list.indexWhere((a) => a.id == attendance.id);
    if (index >= 0) {
      list[index] = attendance;
    } else {
      list.insert(0, attendance);
    }
    await saveAttendances(list);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseService.saveAttendance(attendance);
      } catch (_) {}
    }
  }
}

