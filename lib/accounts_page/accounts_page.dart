import 'dart:math';

import 'package:flutter/material.dart';
import 'package:protect_it/account_details/account_details.dart';
import 'package:protect_it/accounts_page/account_widget.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/attribute.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/shake.dart';
import 'package:protect_it/settings_page/settings_page.dart';
import 'package:provider/provider.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        title: const SearchWidget(),
      ),
      body: Consumer<AccountNotifier>(builder: (context, accountNot, _) {
        if (accountNot.loading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        }
        List<Account> accounts = accountNot.accounts();
        if (accounts.isEmpty) {
          if (accountNot.searchQ.isNotEmpty) {
            return const Center(
                child: Text("No accounts found",
                    style: TextStyle(color: Colors.grey, fontSize: 30)));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 100,
                  color: Colors.black26,
                ),
                const SizedBox(height: 20),
                Text(
                  "No accounts yet",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Add your first account using the + button",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                mainAxisExtent: 200,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            padding: const EdgeInsets.all(10),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return AccountWidget(account: accounts[index]);
            });
      }),
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

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    Shake().start();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _animationController.forward();
      } else if (controller.text.isEmpty) {
        _animationController.reverse();
      }
    });
    _animationController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountNotifier>(context, listen: false).getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  final _border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(999)),
      borderSide: BorderSide(color: Colors.transparent));

  final _iconWidth = 45.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountNotifier>(builder: (context, accountNot, _) {
      return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: _iconWidth,
            maxWidth: _animation.value * 2300 + _iconWidth),
        child: TextField(
          focusNode: focusNode,
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: SizedBox(
              width: _iconWidth,
              child: IconButton(
                onPressed: _iconPressed,
                icon: Icon(
                  focusNode.hasFocus ? Icons.close : Icons.search,
                  color: Colors.black,
                ),
              ),
            ),
            fillColor: Color.lerp(
                Colors.white, Colors.black, min(_animation.value, 0.25)),
            filled: true,
            enabledBorder: _border,
            focusedBorder: _border,
          ),
          controller: controller,
          onChanged: (v) {
            accountNot.updateSearchQ(v);
          },
        ),
      );
    });
  }

  void _iconPressed() {
    if (focusNode.hasFocus) {
      controller.clear();
      focusNode.unfocus();
      Provider.of<AccountNotifier>(context, listen: false).updateSearchQ("");
    } else {
      focusNode.requestFocus();
    }
  }
}
