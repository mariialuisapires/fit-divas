import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/weight_goal_model.dart';

class WeightProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  WeightGoalModel? _activeGoal;
  List<WeightGoalHistoryItem> _goalHistory = [];
  bool _isLoading = false;
  String? _error;

  WeightGoalModel? get activeGoal => _activeGoal;
  List<WeightGoalHistoryItem> get goalHistory => _goalHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActiveGoal() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.weightGoalActive);
      _activeGoal = data != null ? WeightGoalModel.fromJson(data) : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoalHistory() async {
    try {
      final data = await _api.get(ApiConstants.weightGoalHistory) as List;
      _goalHistory = data.map((g) => WeightGoalHistoryItem.fromJson(g)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> createGoal(double pesoAtual, double pesoMeta) async {
    _setLoading(true);
    try {
      final data = await _api.post(ApiConstants.weightGoal, {
        'pesoAtual': pesoAtual,
        'pesoMeta': pesoMeta,
      });
      _activeGoal = WeightGoalModel.fromJson(data);
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

  void setActiveGoal(WeightGoalModel goal) {
    _activeGoal = goal;
    notifyListeners();
  }

  Future<bool> addWeight(double peso) async {
    try {
      await _api.post(ApiConstants.weight, {'peso': peso});
      await loadActiveGoal();
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
