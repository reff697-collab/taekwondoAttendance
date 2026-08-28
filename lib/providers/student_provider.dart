import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';

class StudentProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';
  BeltRank? _selectedBeltFilter;

  StudentProvider(this._storageService) {
    loadStudents();
  }

  List<StudentModel> get allStudents => _students;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  BeltRank? get selectedBeltFilter => _selectedBeltFilter;

  List<StudentModel> get filteredStudents {
    return _students.where((student) {
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBelt = _selectedBeltFilter == null ||
          student.beltRank == _selectedBeltFilter;
      return matchesSearch && matchesBelt;
    }).toList();
  }

  int get totalActiveStudents => _students.length;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    _students = await _storageService.getStudents();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setBeltFilter(BeltRank? belt) {
    _selectedBeltFilter = belt;
    notifyListeners();
  }

  Future<void> addStudent({
    required String name,
    required BeltRank beltRank,
    required DateTime joinDate,
    String? phoneNumber,
    String? notes,
  }) async {
    final newStudent = StudentModel(
      id: 'std_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      beltRank: beltRank,
      joinDate: joinDate,
      phoneNumber: phoneNumber,
      notes: notes,
    );

    _students.insert(0, newStudent);
    notifyListeners();
    await _storageService.saveStudent(newStudent);
  }

  Future<void> updateStudent(StudentModel updated) async {
    final idx = _students.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      _students[idx] = updated;
      notifyListeners();
      await _storageService.saveStudent(updated);
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
    await _storageService.deleteStudent(studentId);
  }
}

