import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import 'token_storage.dart';

/// Excepción de dominio para errores de la API, con un mensaje ya legible.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Cliente HTTP de bajo nivel para la API REST del backend.
///
/// Adjunta automáticamente el token JWT, serializa/deserializa JSON y traduce
/// las respuestas de error a [ApiException]. Aísla el resto de la app del
/// paquete `http`.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, http.Client? client})
      : _tokenStorage = tokenStorage,
        _http = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;

  static const Duration _timeout = Duration(seconds: 15);

  Future<dynamic> get(String path, {bool auth = true}) {
    return _send(() => _http
        .get(_uri(path), headers: _headers(auth))
        .timeout(_timeout));
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) {
    return _send(() => _http
        .post(_uri(path), headers: _headers(auth), body: jsonEncode(body))
        .timeout(_timeout));
  }

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) {
    return _send(() => _http
        .patch(_uri(path), headers: _headers(auth), body: jsonEncode(body))
        .timeout(_timeout));
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> _headers(bool auth) {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (auth && _tokenStorage.hasToken) {
      headers['Authorization'] = 'Bearer ${_tokenStorage.token}';
    }
    return headers;
  }

  /// Ejecuta la petición, gestiona errores de red y decodifica la respuesta.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw const ApiException(
        'No se pudo conectar con el servidor. Verifica tu red y que el '
        'backend esté en ejecución.',
      );
    }
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final dynamic body =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final String message = (body is Map && body['error'] is String)
        ? body['error'] as String
        : 'Error del servidor (${response.statusCode})';
    throw ApiException(message, response.statusCode);
  }
}
