import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/prefs.dart';

class Backend {
  Backend._();
  static final _instance = Backend._();
  factory Backend() => _instance;

  final String _url = "account-safe-api.vercel.app";
  // final String _url = "127.0.0.1:5000";
  final bool _secure = true;

  Future<Response> _makeRequest(String path,
      {Map<String, dynamic>? data, bool secure = true}) async {
    data ??= {};
    try {
      final url = _secure ? Uri.https(_url, path) : Uri.http(_url, path);
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            if (Prefs.getAccessToken().isNotEmpty)
              "Authorization": "Bearer ${Prefs.getAccessToken()}"
          },
          body: jsonEncode(data));
      dynamic r = jsonDecode(response.body);
      return Response(ok: response.statusCode == 200, data: r);
    } catch (e) {
      return Response(ok: false, data: e.toString());
    }
  }

  void ping() async {
    final r = await _makeRequest("/");
    debugPrint(r.ok ? "Success" : "Fail");
    debugPrint(r.data.toString());
  }

  Future<String?> register(String username, String password) async {
    final r = await _makeRequest("/register",
        data: {"username": username, "password": password}, secure: false);
    if (r.ok) {
      return null;
    }
    if (r.data is Map<String, dynamic>) {
      return r.data['message'];
    }
    return "Uknown Error";
  }

  Future<String?> login(String username, String password) async {
    final r = await _makeRequest("/login",
        data: {"username": username, "password": password}, secure: false);
    if (r.ok) {
      Prefs.setAccessToken(r.data['access_token']);
      Prefs.setUsername(username);
      Prefs.setPassword(password);
      return null;
    }
    Prefs.logout();
    if (r.data is Map<String, dynamic>) {
      return r.data['message'];
    }
    return "Uknown Error";
  }

  Future<List<Account>?> getAccounts() async {
    final r = await _makeRequest("/accounts");
    if (r.ok) {
      List<Account> accounts = [];
      List<dynamic> data = r.data['accounts'];
      for (String s in data) {
        Account? a = Account.fromJSON(s);
        if (a == null) {
          return null;
        }
        accounts.add(a);
      }
      return accounts;
    }
    return [];
  }

  Future<Response> setAccount(Account account) async {
    final r = await _makeRequest("/accounts/set",
        data: {"account": account.toJSON(), "id": account.id});
    return r;
  }

  Future<Response> deleteAccount(String id) async {
    final r = await _makeRequest("/accounts/delete", data: {"id": id});
    return r;
  }
}

class Response {
  bool ok;
  dynamic data;

  Response({required this.ok, required this.data});
}
