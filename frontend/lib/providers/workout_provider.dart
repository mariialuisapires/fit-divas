import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _error;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.workouts) as List;
      _workouts = data.map((w) => WorkoutModel.fromJson(w)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createWorkout(String nome, String? observacoes, List<ExerciseModel> exercicios) async {
    _setLoading(true);
    try {
      final data = await _api.post(ApiConstants.workouts, {
        'nome': nome,
        'observacoes': observacoes,
        'exercicios': exercicios.map((e) => e.toJson()).toList(),
      });
      _workouts.add(WorkoutModel.fromJson(data));
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

  Future<bool> deleteWorkout(String id) async {
    try {
      await _api.delete(ApiConstants.workoutById(id));
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> completeWorkout(String id) async {
    try {
      await _api.post(ApiConstants.completeWorkout(id), {});
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
