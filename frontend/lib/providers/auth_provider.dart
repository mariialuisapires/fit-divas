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

  AuthProvider() {
    // Quando o ApiClient não conseguir renovar a sessão, faz logout automático
    ApiClient().onSessionExpired = () {
      _user = null;
      notifyListeners();
    };
  }

  Future<bool> login(String email, String senha) async {
    _setLoading(true);
    try {
      final data = await _api.post(
        ApiConstants.login,
        {'email': email, 'senha': senha},
        auth: false,
      );
      await AuthStorage.saveAuth(
          data['token'], data['refreshToken'], data['userId'].toString(), data['nome']);
      await loadProfile();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String nome, String email, String senha) async {
    _setLoading(true);
    try {
      final data = await _api.post(
        ApiConstants.register,
        {'nome': nome, 'email': email, 'senha': senha},
        auth: false,
      );
      await AuthStorage.saveAuth(
          data['token'], data['refreshToken'], data['userId'].toString(), data['nome']);
      _user = UserModel(
          id: data['userId'].toString(), nome: data['nome'], email: data['email']);
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

  Future<Map<String, dynamic>?> completeOnboarding({
    required String genero,
    required String objetivo,
    required int idade,
    required double altura,
    required double pesoAtual,
    required double pesoMeta,
  }) async {
    try {
      final data = await _api.post(ApiConstants.onboarding, {
        'genero': genero,
        'objetivo': objetivo,
        'idade': idade,
        'altura': altura,
        'pesoAtual': pesoAtual,
        'pesoMeta': pesoMeta,
      }) as Map<String, dynamic>;
      _user = UserModel.fromJson(data['user']);
      _error = null;
      notifyListeners();
      return data;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProfile({
    String? nome,
    String? genero,
    String? objetivo,
    int? idade,
    double? altura,
    double? pesoAtual,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nome != null) body['nome'] = nome;
      if (genero != null) body['genero'] = genero;
      if (objetivo != null) body['objetivo'] = objetivo;
      if (idade != null) body['idade'] = idade;
      if (altura != null) body['altura'] = altura;
      if (pesoAtual != null) body['pesoAtual'] = pesoAtual;
      await _api.put(ApiConstants.profile, body);
      await loadProfile();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> deleteAccount(String senha) async {
    try {
      await _api.deleteWithBody(ApiConstants.deleteAccount, {'senha': senha});
      await AuthStorage.clear();
      _user = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
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
