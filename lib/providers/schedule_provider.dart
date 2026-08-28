import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../services/storage_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;

  ScheduleProvider(this._storageService) {
    loadSchedules();
  }

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;

  ScheduleModel? get todaySchedule {
    final todayWeekday = DateTime.now().weekday; // 1 = Monday ... 7 = Sunday
    try {
      return _schedules.firstWhere((s) => s.dayOfWeek == todayWeekday);
    } catch (_) {
      return _schedules.isNotEmpty ? _schedules.first : null;
    }
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    notifyListeners();

    _schedules = await _storageService.getSchedules();
    // Sort by day of week
    _schedules.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSchedule({
    required String sessionName,
    required String day,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? category,
  }) async {
    final newSchedule = ScheduleModel(
      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      sessionName: sessionName,
      day: day,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      category: category,
    );

    _schedules.add(newSchedule);
    _schedules.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    notifyListeners();
    await _storageService.saveSchedule(newSchedule);
  }

  Future<void> updateSchedule(ScheduleModel updated) async {
    final idx = _schedules.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      _schedules[idx] = updated;
      _schedules.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      notifyListeners();
      await _storageService.saveSchedule(updated);
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
    await _storageService.deleteSchedule(scheduleId);
  }
}

