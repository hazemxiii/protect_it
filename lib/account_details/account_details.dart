import 'package:flutter/material.dart';
import 'package:protect_it/account_details/attribute_custom_widgets.dart';
import 'package:protect_it/account_details/attribute_details.dart';
import 'package:protect_it/home.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key, required this.account});

  final Account account;

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  late AccountNotifier accountNotifer;
  late final TextEditingController accountNameCont;

  @override
  void initState() {
    accountNotifer = Provider.of(context, listen: false);
    accountNameCont = TextEditingController(text: widget.account.name);
    super.initState();
  }

  @override
  void dispose() {
    accountNameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(widget.account.color, Colors.white, 0.9),
      appBar: AppBar(
        title: TextField(
          onChanged: _onType,
          cursorColor: Colors.white,
          decoration: const InputDecoration(border: InputBorder.none),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          controller: accountNameCont,
        ),
        backgroundColor: widget.account.color,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _button(Icons.add, _showEditDialog),
          _button(Icons.delete_outline_rounded, _showDeleteDialog),
          _colorButton()
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height - 200,
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 250,
                maxCrossAxisExtent: 250),
            children: [
              ...widget.account.attributes.entries.map((e) {
                return AttributeWidget(
                  account: widget.account,
                  type: _getType(e.key),
                  attr: e.value,
                  attributeKey: e.key,
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    Map<String, Attribute> attr = accountNotifer.addAttribute(widget.account);
    showDialog(
        context: context,
        builder: (_) => EditAttributeWidget(
            attr: attr.values.toList()[0],
            account: widget.account,
            attrKey: attr.keys.toList()[0]));
  }

  void _onType(String? v) {
    if ((v ?? "").trim() != "") {
      accountNotifer.updateName(widget.account, v!);
    }
  }

  IconButton _button(IconData icon, VoidCallback function) {
    return IconButton(
        color: Colors.white, onPressed: function, icon: Icon(icon));
  }

  void _showDeleteDialog() {
    TextStyle style = TextStyle(color: widget.account.color);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor:
                  Color.lerp(Colors.white, widget.account.color, 0.2),
              title: Text(
                "Are You Sure To Delete ${widget.account.name}?",
                style: style,
              ),
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text("Cancel", style: style)),
                TextButton(
                    onPressed: () {
                      accountNotifer.deleteAccount(widget.account);
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => Consumer(
                                  builder: (context, accountNot, _) =>
                                      const Home())),
                          (_) => false);
                    },
                    child: Text("Delete", style: style))
              ],
            ));
  }

  InkWell _colorButton() {
    return InkWell(
      onTap: _showColorPicker,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            border: const Border.fromBorderSide(
                BorderSide(width: 3, color: Colors.white)),
            color: widget.account.color,
            borderRadius: const BorderRadius.all(Radius.circular(999))),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: SingleChildScrollView(
                child: ColorPicker(
                    pickerColor: widget.account.color,
                    onColorChanged: (c) {
                      accountNotifer.updateColor(widget.account, c);
                    }),
              ),
            ));
  }

  AttributeType _getType(String attributeKey) {
    if (attributeKey == widget.account.mainKey) {
      return AttributeType.main;
    }
    if (attributeKey == widget.account.secKey) {
      return AttributeType.secondary;
    }
    return AttributeType.normal;
  }
}

enum AttributeType { normal, main, secondary }
