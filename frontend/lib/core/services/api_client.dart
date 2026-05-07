import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_storage.dart';

class ApiClient {
  // Singleton — uma única instância compartilhada em todo o app
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  // Callback chamado quando o refresh token também expirou
  void Function()? onSessionExpired;

  // Previne múltiplos refreshes simultâneos
  bool _isRefreshing = false;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Tenta renovar o access token usando o refresh token
  Future<bool> _tryRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(ApiConstants.refresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await AuthStorage.saveAuth(
          data['token'],
          data['refreshToken'],
          data['userId'].toString(),
          data['nome'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<dynamic> _execute(
    Future<http.Response> Function(Map<String, String> headers) request, {
    bool auth = true,
    bool isRetry = false,
  }) async {
    final headers = await _headers(auth: auth);
    final response = await request(headers);

    // Token expirado — tenta refresh uma vez
    if (response.statusCode == 401 && auth && !isRetry) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _headers(auth: true);
        final retryResponse = await request(retryHeaders);
        return _parse(retryResponse);
      } else {
        // Refresh também falhou — sessão encerrada
        await AuthStorage.clear();
        onSessionExpired?.call();
        throw ApiException('Sessão expirada. Faça login novamente.', 401);
      }
    }

    return _parse(response);
  }

  Future<dynamic> get(String url) =>
      _execute((h) => http.get(Uri.parse(url), headers: h));

  Future<dynamic> post(String url, Map<String, dynamic> body,
          {bool auth = true}) =>
      _execute(
        (h) => http.post(Uri.parse(url), headers: h, body: jsonEncode(body)),
        auth: auth,
      );

  Future<dynamic> put(String url, Map<String, dynamic> body) =>
      _execute(
        (h) => http.put(Uri.parse(url), headers: h, body: jsonEncode(body)),
      );

  Future<void> delete(String url) async {
    await _execute((h) => http.delete(Uri.parse(url), headers: h));
  }

  dynamic _parse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    _throwError(response);
  }

  Never _throwError(http.Response response) {
    String message = 'Erro desconhecido';
    try {
      final body = jsonDecode(response.body);
      message = body['error'] ?? body['message'] ?? message;
    } catch (_) {}
    throw ApiException(message, response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
