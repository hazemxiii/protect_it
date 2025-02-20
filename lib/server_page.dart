import 'package:flutter/material.dart';
import 'package:protect_it/secret_code.dart';
import 'package:protect_it/service/sync_data.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  bool _isLoading = true;
  String _ip = "";

  @override
  void initState() {
    SyncData().startServer(context, _onConnect, _onReceive);
    super.initState();
  }

  @override
  dispose() {
    SyncData().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(
                      color: Color.lerp(Colors.white, Colors.black, 0.1)!)),
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Server ${_isLoading ? "Loading" : "Listening"}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: _isLoading ? Colors.red : Colors.green,
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        "The server is ${_isLoading ? "loading" : "now waiting for incoming file"}"),
                  ),
                  Text(
                    "Server IP: $_ip",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (!_isLoading)
                    MaterialButton(
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      color: Colors.red,
                      onPressed: _stopServer,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Stop Server"),
                        ],
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _stopServer() {
    SyncData().close();
    Navigator.of(context).pop();
  }

  void _onConnect(String ip) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _ip = ip;
      });
    }
  }

  void _onReceive() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SecretCodePage()),
        (_) => false);
  }
}
