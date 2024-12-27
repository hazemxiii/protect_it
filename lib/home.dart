import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AccountNotifier>(context, listen: false).addAccount(
              Account(
                  color: Colors.red,
                  mainKey: "user",
                  secKey: "pass",
                  name: "valo",
                  attributes: {
                "user": Attribute(value: "hazemXIII"),
                "pass": Attribute(value: "dispass", isSensitive: true)
              }));
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Consumer<AccountNotifier>(builder: (context, accountNot, _) {
          return Text("Accounts: ${accountNot.accounts.length}");
        }),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Consumer<AccountNotifier>(builder: (context, accountNot, _) {
            return Column(
              children: [
                ...accountNot.accounts.map((account) {
                  return AccountWidget(
                    account: account,
                  );
                })
              ],
            );
          }),
        ),
      ),
    );
  }
}

class AccountWidget extends StatefulWidget {
  final Account account;
  const AccountWidget({
    super.key,
    required this.account,
  });

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  bool isSensitiveShown = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.account.name,
            style: TextStyle(color: widget.account.color),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Color.lerp(Colors.white, widget.account.color, 0.1),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _displayAttribute(widget.account.getMain),
                    _displayAttribute(widget.account.getSec),
                  ],
                ),
                IconButton(
                    color: widget.account.color,
                    onPressed: () {
                      setState(() {
                        isSensitiveShown = !isSensitiveShown;
                      });
                    },
                    icon: Icon(isSensitiveShown
                        ? Icons.visibility
                        : Icons.visibility_off))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text _displayAttribute(Attribute atr) {
    String txt;
    if (isSensitiveShown || !atr.isSensitive) {
      txt = atr.value;
    } else {
      txt = "".padLeft(atr.value.length, "*");
    }
    return Text(
      txt,
      style: TextStyle(color: widget.account.color),
    );
  }
}
