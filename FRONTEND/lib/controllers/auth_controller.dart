import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // ── Usuario demo (sin backend) ───────────────────────────────────
    if (email.trim() == 'demo@jamtech.com' && password == '123456') {
      await Future.delayed(const Duration(milliseconds: 800)); // simula latencia
      _currentUser = UserModel(
        nombre: 'Admin Demo',
        email: 'demo@jamtech.com',
        password: '123456',
        birthdate: '1990-01-01',
        gender: 'Masculino',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
    // ────────────────────────────────────────────────────────────────

    try {
      final result = await _apiService.login(email, password);

      if (result['success']) {
        final userData = result['data'];
        final token = result['token'];

        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
        }

        if (token != null) {
          await _saveSession(email, token);
          // Configurar token en ApiService para futuras peticiones
          ApiService.authToken = token;
        }

        // Si no vino el user data pero si el token, intentar obtener perfil
        if (_currentUser == null && token != null) {
          final user = await _apiService.getUser(email);
          if (user != null) {
            _currentUser = user;
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(user);

      if (result['success']) {
        _currentUser = UserModel.fromJson(result['data']);
        // Nota: El registro usualmente no devuelve token inmediato en este backend,
        // pero si lo hiciera deberíamos guardarlo.
        // Por ahora asumimos que el usuario debe loguearse o el backend se updatea para devolver token.
        // Si el backend no devuelve token en register, el usuario tendrá que hacer login.
        // Para mantener consistencia con flujo actual, guardamos email pero sin token (o login automático)
        // Idealmente: Auto-login tras registro.

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    ApiService.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('auth_token');
    notifyListeners();
  }

  // Guardar sesión en SharedPreferences
  Future<void> _saveSession(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('auth_token', token);
  }

  // Restaurar sesión
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final token = prefs.getString('auth_token');

      if (email != null && token != null) {
        // Restaurar token en memoria
        ApiService.authToken = token;

        // Verificar validez del token obteniendo perfil
        final user = await _apiService.getUser(email);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        } else {
          // Si falla obtener usuario (ej. token expirado), cerrar sesión limpia
          await logout();
        }
      }
    } catch (e) {
      // Error silencioso en restore
      await logout();
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.forgotPassword(email);

    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  // Reset Password
  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.resetPassword(token, newPassword);

    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  // Actualizar perfil
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updateUser(
        updatedUser.email,
        updatedUser,
      );

      if (result['success'] && result['data'] != null) {
        _currentUser = UserModel.fromJson(result['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Eliminar cuenta
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteUser(_currentUser!.email);

      if (success) {
        await logout(); // Limpiar sesión local
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'No se pudo eliminar la cuenta. Intenta nuevamente.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al eliminar cuenta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
