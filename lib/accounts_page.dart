import 'package:flutter/material.dart';
import 'package:protect_it/account_details/account_details.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/global.dart';
import 'package:protect_it/settings_page/settings.dart';
import 'package:provider/provider.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _addAccount(context),
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              color: Colors.black,
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings)),
        ],
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
                  return AccountWidget(account: account);
                })
              ],
            );
          }),
        ),
      ),
    );
  }

  void _addAccount(BuildContext context) {
    Account account = Account(
        color: Colors.black,
        mainKey: "userName",
        secKey: "password",
        name: "Account",
        attributes: {
          "userName": Attribute(value: "userName"),
          "password": Attribute(value: "password", isSensitive: true)
        });
    Provider.of<AccountNotifier>(context, listen: false).addAccount(account);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            Consumer<AccountNotifier>(builder: (context, accountNotifier, _) {
              return AccountDetailsPage(account: account);
            })));
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
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: _openDetails,
      child: Container(
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
                      _displayAttribute(widget.account.mainAttr),
                      if (widget.account.secAttr != null)
                        _displayAttribute(widget.account.secAttr!),
                    ],
                  ),
                  Row(
                    children: [
                      _copyWidget(),
                      IconButton(
                          color: widget.account.color,
                          onPressed: _toggleShowSensitive,
                          icon: Icon(isSensitiveShown
                              ? Icons.visibility
                              : Icons.visibility_off)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            Consumer<AccountNotifier>(builder: (context, accountNot, _) {
              return AccountDetailsPage(account: widget.account);
            })));
  }

  void _toggleShowSensitive() {
    setState(() {
      isSensitiveShown = !isSensitiveShown;
    });
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

  Widget _copyWidget() {
    if (widget.account.secKey == "") {
      return IconButton(
          color: widget.account.color,
          onPressed: () => copy(
              context, widget.account.color, widget.account.mainAttr.value),
          icon: const Icon(Icons.copy));
    }
    return PopupMenuButton(
        iconColor: widget.account.color,
        color: widget.account.color,
        onSelected: (v) => copy(context, widget.account.color, v.value),
        itemBuilder: (_) => [
              PopupMenuItem(
                  value: widget.account.mainAttr,
                  child: Text(
                    "Copy ${widget.account.mainKey}",
                    style: const TextStyle(color: Colors.white),
                  )),
              PopupMenuItem(
                  value: widget.account.secAttr,
                  child: Text("Copy ${widget.account.secKey}",
                      style: const TextStyle(color: Colors.white)))
            ]);
  }
}
