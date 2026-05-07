import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../core/services/auth_storage.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String senha) async {
    _setLoading(true);
    try {
      final data = await _api.post(
        ApiConstants.login,
        {'email': email, 'senha': senha},
        auth: false,
      );
      await AuthStorage.saveAuth(data['token'], data['userId'], data['nome']);
      _user = UserModel(
        id: data['userId'],
        nome: data['nome'],
        email: data['email'],
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String nome, String email, String senha, {double? pesoAtual, double? pesoMeta}) async {
    _setLoading(true);
    try {
      final data = await _api.post(
        ApiConstants.register,
        {
          'nome': nome,
          'email': email,
          'senha': senha,
          'pesoAtual': pesoAtual,
          'pesoMeta': pesoMeta,
        },
        auth: false,
      );
      await AuthStorage.saveAuth(data['token'], data['userId'], data['nome']);
      _user = UserModel(
        id: data['userId'],
        nome: data['nome'],
        email: data['email'],
        pesoAtual: pesoAtual,
        pesoMeta: pesoMeta,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await _api.get(ApiConstants.profile);
      _user = UserModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> checkAuth() async {
    if (await AuthStorage.isLoggedIn()) {
      await loadProfile();
    }
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
