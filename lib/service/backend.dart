import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/widgets/logout_snackbar.dart';

class Backend {
  Backend._();
  static final _instance = Backend._();
  factory Backend() => _instance;
  bool? _otpEnabled;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<Response> _makeRequest(String path,
      {Map<String, dynamic>? data, bool authorized = true}) async {
    bool secure = kReleaseMode;
    // ignore: dead_code
    String mainPath = secure ? "account-safe-api.vercel.app" : "127.0.0.1:5000";
    data ??= {};
    try {
      // ignore: dead_code
      final url = secure ? Uri.https(mainPath, path) : Uri.http(mainPath, path);
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            if (Prefs().getAccessToken().isNotEmpty)
              "Authorization": "Bearer ${Prefs().getAccessToken()}"
          },
          body: jsonEncode(data));
      dynamic r = jsonDecode(response.body);
      if (r is Map<String, dynamic>) {
        if (r['message'] == "Invalid token") {
          _logout();
        }
      }
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

  Future<bool?> isLoggedIn() async {
    final r = await _makeRequest("/");
    if (r.ok) {
      if (r.data['error']) {
        return null;
      }
      return r.data['loggedIn'];
    }
    return null;
  }

  Future<String?> register(String username, String password) async {
    final r = await _makeRequest("/register",
        data: {"username": username, "password": password}, authorized: false);
    if (r.ok) {
      return null;
    }
    if (r.data is Map<String, dynamic>) {
      return r.data['message'];
    }
    return "Unknown Error";
  }

  Future<String?> login(String username, String password, {String? otp}) async {
    final r = await _makeRequest("/login",
        data: {"username": username, "password": password, "otp": otp},
        authorized: false);
    debugPrint(r.data.toString());
    if (r.ok) {
      if ((r.data as Map<String, dynamic>).containsKey('access_token')) {
        Prefs().login(username, password, r.data['access_token']);
        return null;
      }
      _otpEnabled = r.data['otpEnabled'];
      return null;
    }
    if (r.data is Map<String, dynamic>) {
      String message = r.data['message'];
      // if (message == "Invalid token") {
      //   Prefs().logout();
      // }
      return message;
    }
    return "Unknown Error";
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

  Future<bool?> setOtp(bool otp) async {
    final r = await _makeRequest("/otp/set", data: {"otp": otp});
    if (r.ok) {
      _otpEnabled = r.data['otp'];
      return r.data['otp'];
    }
    return null;
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

  void _logout() {
    Prefs().logout();
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(_signOutWidget());
  }

  SnackBar _signOutWidget() {
    return SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Color.lerp(Colors.blue, Colors.white, 0.9),
        behavior: SnackBarBehavior.floating,
        content: const LogoutSnackbar());
  }

  Future<bool> get otpEnabled async {
    if (_otpEnabled != null) {
      return _otpEnabled!;
    }
    final r = await _makeRequest("/otp/get");
    if (r.ok) {
      _otpEnabled = r.data['otp'];
    }
    return _otpEnabled ?? false;
  }
}

class Response {
  bool ok;
  dynamic data;

  Response({required this.ok, required this.data});
}
