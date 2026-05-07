import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../models/calendar_model.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  CalendarMonth? _currentMonth;
  bool _isLoading = false;
  String? _error;

  CalendarMonth? get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMonth({int? year, int? month}) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final y = year ?? now.year;
      final m = month ?? now.month;
      final data = await _api.get('${ApiConstants.calendar}?year=$y&month=$m');
      _currentMonth = CalendarMonth.fromJson(data);
      _error = null;
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
