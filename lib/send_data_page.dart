import 'package:flutter/material.dart';
import 'package:protect_it/service/sync_data.dart';

class SendDataPage extends StatefulWidget {
  const SendDataPage({super.key});

  @override
  State<SendDataPage> createState() => _SendDataPageState();
}

class _SendDataPageState extends State<SendDataPage> {
  @override
  void initState() {
    SyncData().scanNetwork(_onFound);
    super.initState();
  }

  List<String> ips = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Select Server"),
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      body: ips.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No Servers Found",
                    style: TextStyle(fontSize: 30),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: ips.map((ip) {
                  return _serverWidget("Server ${ips.indexOf(ip) + 1}", ip);
                }).toList(),
              ),
            ),
    );
  }

  Widget _serverWidget(String name, String ip) {
    final grey = Color.lerp(Colors.black, Colors.white, 0.5);
    final textStyle = TextStyle(color: grey);
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.fromBorderSide(
              BorderSide(color: Color.lerp(Colors.white, Colors.black, 0.1)!))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _circleWidget()
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.devices,
                color: grey,
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  ip,
                  style: textStyle,
                ),
              )
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: grey,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                "Connected",
                style: textStyle,
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          MaterialButton(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.black,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            onPressed: () => _sendData(ip),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Send File",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _circleWidget() {
    double size = 10;
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(999))),
    );
  }

  void _onFound(String ip) {
    if (mounted) {
      setState(() {
        ips.add(ip);
      });
    }
  }

  void _sendData(String ip) async {
    await SyncData().sendData(ip, false);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
