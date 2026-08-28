import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/schedule_model.dart';
import '../models/attendance_model.dart';

class FirebaseService {
  static bool _isFirebaseInitialized = false;

  static bool get isInitialized => _isFirebaseInitialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
    } catch (e) {
      _isFirebaseInitialized = false;
      // App will gracefully continue in local/offline storage mode
    }
  }

  // --- AUTH ---
  static FirebaseAuth? get _auth =>
      _isFirebaseInitialized ? FirebaseAuth.instance : null;

  static User? get currentUser => _auth?.currentUser;

  static Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    if (!_isFirebaseInitialized || _auth == null) return null;
    return await _auth!.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() async {
    if (!_isFirebaseInitialized || _auth == null) return;
    await _auth!.signOut();
  }

  // --- FIRESTORE COLLECTIONS ---
  static FirebaseFirestore? get _db =>
      _isFirebaseInitialized ? FirebaseFirestore.instance : null;

  static CollectionReference? get _studentsCol =>
      _db?.collection('students');

  static CollectionReference? get _schedulesCol =>
      _db?.collection('schedules');

  static CollectionReference? get _attendancesCol =>
      _db?.collection('attendances');

  // Students CRUD
  static Future<List<StudentModel>> fetchStudents() async {
    if (_studentsCol == null) return [];
    final snapshot = await _studentsCol!.where('isActive', isEqualTo: true).get();
    return snapshot.docs
        .map((d) =>
            StudentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<void> saveStudent(StudentModel student) async {
    if (_studentsCol == null) return;
    if (student.id.isEmpty) {
      await _studentsCol!.add(student.toMap());
    } else {
      await _studentsCol!.doc(student.id).set(student.toMap(), SetOptions(merge: true));
    }
  }

  static Future<void> deleteStudent(String studentId) async {
    if (_studentsCol == null) return;
    await _studentsCol!.doc(studentId).update({'isActive': false});
  }

  // Schedules CRUD
  static Future<List<ScheduleModel>> fetchSchedules() async {
    if (_schedulesCol == null) return [];
    final snapshot = await _schedulesCol!.orderBy('dayOfWeek').get();
    return snapshot.docs
        .map((d) =>
            ScheduleModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<void> saveSchedule(ScheduleModel schedule) async {
    if (_schedulesCol == null) return;
    if (schedule.id.isEmpty) {
      await _schedulesCol!.add(schedule.toMap());
    } else {
      await _schedulesCol!.doc(schedule.id).set(schedule.toMap(), SetOptions(merge: true));
    }
  }

  static Future<void> deleteSchedule(String scheduleId) async {
    if (_schedulesCol == null) return;
    await _schedulesCol!.doc(scheduleId).delete();
  }

  // Attendances CRUD
  static Future<List<AttendanceModel>> fetchAttendances() async {
    if (_attendancesCol == null) return [];
    final snapshot = await _attendancesCol!.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((d) =>
            AttendanceModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<void> saveAttendance(AttendanceModel attendance) async {
    if (_attendancesCol == null) return;
    await _attendancesCol!.doc(attendance.id).set(
          attendance.toMap(),
          SetOptions(merge: true),
        );
  }
}

