import 'dart:io';
import 'package:flutter/material.dart';
import 'package:protect_it/service/file.dart';

class SyncData {
  static ServerSocket? _server;
  Future<bool> startServer(BuildContext context, Function(String ip) onConnect,
      Function onReceive) async {
    String? ip;
    try {
      ip = await _getLocalIpAddress();
    } catch (e) {
      print(e);
    }
    if (ip == null) {
      return false;
    }
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      5000,
    );
    onConnect(ip);
    await for (Socket client in _server!) {
      await client.listen((data) async {
        await FileHolder().writeFromList(data);
        onReceive();
        _server!.close();
      }).asFuture();
    }
    return true;
    // return ip;
  }

  void close() {
    if (_server != null) {
      _server!.close();
    }
  }

  void sendData(String ip) async {
    List<int> fileBytes = await FileHolder.file!.readAsBytes();

    try {
      Socket socket =
          await Socket.connect(ip, 5000, timeout: const Duration(seconds: 5));
      socket.add(fileBytes);
      await socket.flush();
      await socket.close();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> scanNetwork(Function(String ip) onFound) async {
    String baseIp = '192.168.1.';
    for (int i = 1; i < 255; i++) {
      String ip = '$baseIp$i';
      Socket.connect(ip, 5000, timeout: const Duration(seconds: 1)).then((v) {
        onFound(ip);
      }).catchError((e) {});
    }
  }

  Future<String?> _getLocalIpAddress() async {
    try {
      for (var ntwrk in await NetworkInterface.list()) {
        for (var addr in ntwrk.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
