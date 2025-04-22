import 'package:flutter/material.dart';
import 'package:protect_it/account_details/attribute_custom_widgets.dart';
import 'package:protect_it/accounts_page/account_widget.dart';
import 'package:protect_it/accounts_page/accounts_page.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/attribute.dart';
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
  late final String accountBackUp;

  @override
  void initState() {
    accountNotifer = Provider.of(context, listen: false);
    accountNameCont = TextEditingController(text: widget.account.name);
    accountBackUp = widget.account.toJSON();
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
          cursorColor: Colors.black,
          decoration: const InputDecoration(border: InputBorder.none),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          controller: accountNameCont,
        ),
        backgroundColor: Color.lerp(widget.account.color, Colors.white, 0.9),
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          _button(Icons.add, _showEditDialog),
          _button(Icons.delete_outline_rounded, _showDeleteDialog),
          _colorButton()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(true),
            _section(false),
            const SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: MaterialButton(
                color: widget.account.color,
                onPressed: _cancel,
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   height: MediaQuery.of(context).size.height - 105,
            //   child: GridView(
            //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            //         crossAxisSpacing: 10,
            //         mainAxisSpacing: 10,
            //         mainAxisExtent: 250,
            //         maxCrossAxisExtent: 320),
            //     children: [
            //       ...widget.account.attributes.entries.map((e) {
            //         return AttributeWidget(
            //           account: widget.account,
            //           type: _getType(e.key),
            //           attr: e.value,
            //           attributeKey: e.key,
            //         );
            //       })
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _cancel() async {
    accountNotifer.cancel(widget.account, Account.fromJSON(accountBackUp)!);
    if (mounted) {
      Navigator.of(context).pop();
    }
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
        color: Colors.black, onPressed: function, icon: Icon(icon));
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
                                      const AccountsPage())),
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
        // margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            border: const Border.fromBorderSide(
                BorderSide(width: 3, color: Colors.black)),
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

// TODO: color widget
// TODO: context menu design
  Widget _section(bool isMain) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              if (isMain) _colorButton(),
              Text(isMain ? widget.account.name : "Additional Details",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          Text(isMain ? "Main Details" : "Additional Details"),
          SingleChildScrollView(
              child: Column(
                  spacing: isMain ? 20 : 5,
                  children: _getAttributes(isMain)
                      .entries
                      .map((e) => AccountAttributeWidget(
                            account: widget.account,
                            attribute: e.value,
                            name: e.key,
                            color: widget.account.color,
                            showContextMenu: true,
                          ))
                      .toList()))
        ],
      ),
    );
  }

  Map<String, Attribute> _getAttributes(bool isMain) {
    Map<String, Attribute> attributes = {};
    if (isMain) {
      attributes[widget.account.mainKey] = widget.account.mainAttr;
      if (widget.account.secAttr != null) {
        attributes[widget.account.secKey] = widget.account.secAttr!;
      }
      return attributes;
    }
    for (var e in widget.account.attributes.entries) {
      AttributeType type = _getType(e.key);
      if (type == AttributeType.normal) {
        attributes[e.key] = e.value;
      }
    }
    return attributes;
  }
}

enum AttributeType { normal, main, secondary }
