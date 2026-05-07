import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/water_model.dart';

class WaterProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  WaterSummary? _summary;
  List<WaterMonthlyItem> _monthlyHistory = [];
  bool _isLoading = false;
  String? _error;

  WaterSummary? get summary => _summary;
  List<WaterMonthlyItem> get monthlyHistory => _monthlyHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadToday() async {
    _setLoading(true);
    try {
      final data = await _api.get(ApiConstants.waterToday);
      _summary = WaterSummary.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addWater(int quantidadeMl) async {
    try {
      final data = await _api.post(ApiConstants.water, {'quantidadeMl': quantidadeMl});
      _summary = WaterSummary.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> removeEntry(String id) async {
    try {
      await _api.delete(ApiConstants.waterEntry(id));
      await loadToday();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> loadMonthlyHistory({int? year, int? month}) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final y = year ?? now.year;
      final m = month ?? now.month;
      final data = await _api.get('${ApiConstants.waterHistory}?year=$y&month=$m') as List;
      _monthlyHistory = data.map((e) => WaterMonthlyItem.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
