import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final data = jsonDecode(userJson);
    return data['token'];
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── GET ────────────────────────────────────────────────────
  static Future<dynamic> get(String url) async {
    try {
      final res = await http
          .get(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService GET error: $e');
      return null;
    }
  }

  // ─── POST ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> post(
      String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse(url),
              headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService POST error: $e');
      return null;
    }
  }

  // ─── PUT ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> put(
      String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(Uri.parse(url),
              headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService PUT error: $e');
      return null;
    }
  }

  // ─── DELETE ─────────────────────────────────────────────────
  static Future<bool> delete(String url) async {
    try {
      final res = await http
          .delete(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint('ApiService DELETE error: $e');
      return false;
    }
  }
}
