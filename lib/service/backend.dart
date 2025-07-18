import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/offline_request.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/service/secure_storage.dart';
import 'package:protect_it/widgets/logout_snackbar.dart';

class Backend {
  Backend._();
  static final Backend _instance = Backend._();
  factory Backend() => _instance;
  bool? _otpEnabled;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<Response> _makeRequest(String path,
      {Map<String, dynamic>? data,
      bool authorized = true,
      String? requestType}) async {
    const bool secure = kReleaseMode;
    const String mainPath =
        secure ? 'account-safe-api.vercel.app' : '127.0.0.1:5000';
    data ??= {};
    try {
      final Uri url =
          secure ? Uri.https(mainPath, path) : Uri.http(mainPath, path);
      final http.Response response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            if (SecureStorage().accessToken.isNotEmpty)
              'Authorization': 'Bearer ${SecureStorage().accessToken}'
          },
          body: jsonEncode(data));
      final dynamic r = jsonDecode(response.body);
      if (r is Map<String, dynamic>) {
        if (r['message'] == 'Invalid token') {
          _logout();
        }
      }
      return Response(
          ok: response.statusCode == 200,
          data: r,
          statusCode: response.statusCode);
    } catch (e) {
      if (requestType != null) {
        Prefs().addOfflineRequest(
            OfflineRequest(data: jsonEncode(data), requestType: requestType));
      }
      return Response(ok: false, data: e.toString(), statusCode: 500);
    }
  }

  void ping() async {
    final Response r = await _makeRequest('/');
    debugPrint(r.ok ? 'Success' : 'Fail');
    debugPrint(r.data.toString());
  }

  void sendOfflineRequest() async {}

  Future<bool?> isLoggedIn() async {
    final Response r = await _makeRequest('/');
    if (r.ok) {
      if (r.data['error']) {
        return null;
      }
      return r.data['loggedIn'];
    }
    return null;
  }

  Future<String?> register(String username, String password) async {
    final Response r = await _makeRequest('/register',
        data: {'username': username, 'password': password}, authorized: false);
    if (r.ok) {
      return null;
    }
    if (r.data is Map<String, dynamic>) {
      return r.data['message'];
    }
    return 'Unknown Error';
  }

  Future<String?> login(String username, String password, {String? otp}) async {
    final Response r = await _makeRequest('/login',
        data: {'username': username, 'password': password, 'otp': otp},
        authorized: false);
    if (r.ok) {
      if ((r.data as Map<String, dynamic>).containsKey('access_token')) {
        final Map<String, dynamic> key = r.data['key'];

        final String? decryptedKey = await Encryption().decryptKey(
            encryptedKeyString: key['encrypted_key'],
            password: password,
            saltString: key['salt'],
            ivString: key['iv']);
        if (decryptedKey == null) {
          return 'Unknown Error';
        }
        await Prefs().login(
            username,
            password,
            r.data['access_token'],
            DateTime.now().add(Duration(seconds: r.data['expires_in'])),
            decryptedKey);
        return null;
      }
      _otpEnabled = r.data['otpEnabled'];
      return null;
    }
    if (r.data is Map<String, dynamic>) {
      final String message = r.data['message'];
      // if (message == "Invalid token") {
      //   Prefs().logout();
      // }
      return message;
    }
    return 'Unknown Error';
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    /// Returns null if success, error message if not
    final Response r = await _makeRequest('/change_password',
        data: {'old_password': oldPassword, 'new_password': newPassword});
    if (r.ok) {
      final Map<String, dynamic> key = r.data['key'];

      final String? decryptedKey = await Encryption().decryptKey(
          encryptedKeyString: key['encrypted_key'],
          password: newPassword,
          saltString: key['salt'],
          ivString: key['iv']);
      if (decryptedKey == null) {
        return 'Unknown Error';
      }
      Prefs().login(
          SecureStorage().username,
          newPassword,
          r.data['access_token'],
          DateTime.now().add(Duration(seconds: r.data['expires_in'])),
          decryptedKey);
      return null;
    } else if (r.statusCode == 500) {
      return 'Unknown Error';
    }
    return r.data['message'];
  }

  Future<bool> logout() async {
    final Response r = await _makeRequest('/logout');
    return r.ok;
  }

  Future<List<Account>?> getAccounts() async {
    final Response r = await _makeRequest('/accounts');
    if (r.ok) {
      final List<Account> accounts = <Account>[];
      final List<dynamic> data = r.data['accounts'];
      for (String s in data) {
        final Account? a = Account.fromJSON(s);
        if (a == null) {
          return null;
        }
        accounts.add(a);
      }
      return accounts;
    }
    return <Account>[];
  }

  Future<void> sendOfflineRequests() async {
    final List<OfflineRequest> requests = Prefs().getOfflineRequests();
    for (OfflineRequest request in requests) {
      final String resource =
          request.requestType == 'set' ? '/accounts/set' : '/accounts/delete';
      final Response r = await _makeRequest(
        resource,
        data: jsonDecode(request.data),
      );
      if (r.ok) {
        Prefs().removeOfflineRequest(request);
      }
    }
  }

  Future<bool?> setOtp(bool otp) async {
    final Response r = await _makeRequest('/otp/set', data: {'otp': otp});
    if (r.ok) {
      _otpEnabled = r.data['otp'];
      return r.data['otp'];
    }
    return null;
  }

  Future<Response> setAccount(Account account) async {
    final Response r = await _makeRequest('/accounts/set',
        requestType: 'set',
        data: {'account': account.toJSON(), 'id': account.id});
    return r;
  }

  Future<Response> deleteAccount(String id) async {
    final Response r = await _makeRequest('/accounts/delete',
        requestType: 'delete', data: {'id': id});
    if (r.statusCode == 500) {}
    return r;
  }

  void _logout() {
    Prefs().logout();
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(_signOutWidget());
  }

  SnackBar _signOutWidget() => SnackBar(
      duration: const Duration(seconds: 5),
      backgroundColor: Color.lerp(Colors.blue, Colors.white, 0.9),
      behavior: SnackBarBehavior.floating,
      content: const LogoutSnackbar());

  Future<bool> get otpEnabled async {
    if (_otpEnabled != null) {
      return _otpEnabled!;
    }
    final Response r = await _makeRequest('/otp/get');
    if (r.ok) {
      _otpEnabled = r.data['otp'];
    }
    return _otpEnabled ?? false;
  }
}

class Response {
  bool ok;
  dynamic data;
  int statusCode;

  Response({required this.ok, required this.data, required this.statusCode});
}
