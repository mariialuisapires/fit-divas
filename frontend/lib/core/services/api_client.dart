import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiClient {
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: await _headers());
    return _handle(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body, {bool auth = true}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<void> delete(String url) async {
    final response = await http.delete(Uri.parse(url), headers: await _headers());
    if (response.statusCode >= 400) _throwError(response);
  }

  dynamic _handle(http.Response response) {
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
