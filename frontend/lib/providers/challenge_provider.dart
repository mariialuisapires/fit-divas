import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/challenge_model.dart';

class ChallengeProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  ChallengeModel? _activeChallenge;
  List<ChallengeModel> _challenges = [];
  bool _isLoading = false;
  String? _error;

  ChallengeModel? get activeChallenge => _activeChallenge;
  List<ChallengeModel> get challenges => _challenges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActive() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.challengeActive);
      _activeChallenge = ChallengeModel.fromJson(data);
      _error = null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) _activeChallenge = null;
      else _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.challenges) as List;
      _challenges = data.map((c) => ChallengeModel.fromJson(c)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createChallenge({
    required String nome,
    double? pesoInicial,
    double? pesoMeta,
    required int metaDias,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.post(ApiConstants.challenges, {
        'nome': nome,
        'pesoInicial': pesoInicial,
        'pesoMeta': pesoMeta,
        'metaDiasTreinados': metaDias,
        'dataInicio': dataInicio.toIso8601String(),
        'dataFim': dataFim.toIso8601String(),
      });
      _activeChallenge = ChallengeModel.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> finishChallenge(String id) async {
    try {
      await _api.post(ApiConstants.finishChallenge(id), {});
      _activeChallenge = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
