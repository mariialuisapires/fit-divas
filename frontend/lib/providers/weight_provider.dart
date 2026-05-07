import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/weight_model.dart';

class WeightProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  WeightSummary? _summary;
  bool _isLoading = false;
  String? _error;

  WeightSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSummary() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.weight);
      _summary = WeightSummary.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addWeight(double peso) async {
    try {
      await _api.post(ApiConstants.weight, {'peso': peso});
      await loadSummary();
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
