import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isLoggedIn = false;
  String _coachName = 'Sabeum Nim';
  String _coachEmail = 'sabeum@gta-taekwondo.com';
  String _coachDan = 'Dan IV Black Belt';
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    _init();
  }

  bool get isLoggedIn => _isLoggedIn;
  String get coachName => _coachName;
  String get coachEmail => _coachEmail;
  String get coachDan => _coachDan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _coachName = _storageService.getCoachName();
    // Default logged in to Sabeum demo session for smooth immediate testing
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (FirebaseService.isInitialized) {
        final cred = await FirebaseService.signInWithEmailPassword(email, password);
        if (cred?.user != null) {
          _coachEmail = cred!.user!.email ?? email;
          _isLoggedIn = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      // Offline / Demo validation
      await Future.delayed(const Duration(milliseconds: 600));
      if (email.trim().isNotEmpty && password.trim().length >= 6) {
        _coachEmail = email.trim();
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email tidak valid atau kata sandi minimal 6 karakter.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal masuk: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseService.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateCoachProfile(String name, String dan) {
    _coachName = name;
    _coachDan = dan;
    _storageService.setCoachName(name);
    notifyListeners();
  }
}

