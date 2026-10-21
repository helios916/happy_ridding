import 'dart:convert';

import 'package:http/http.dart' as http;

/// 极简 HTTP 客户端封装：统一 baseUrl、鉴权头与错误处理。
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? _token;

  /// 登录成功后写入 token。
  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path').replace(queryParameters: query),
      headers: _headers,
    );
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body ?? const {}),
    );
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
