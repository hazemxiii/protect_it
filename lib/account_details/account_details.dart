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
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color.lerp(widget.account.color, Colors.white, 0.9),
      appBar: AppBar(
        backgroundColor: Color.lerp(widget.account.color, Colors.white, 0.9),
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: <Widget>[
          _button(Icons.add, _showEditDialog),
          _button(Icons.delete_outline_rounded, _showDeleteDialog),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _section(true),
            _section(false),
            const SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: MaterialButton(
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _cancel,
                child: const Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.cancel_outlined, color: Colors.black),
                    Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  void _cancel() async {
    accountNotifer.cancel(widget.account, Account.fromJSON(accountBackUp)!);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showEditDialog() {
    final Map<String, Attribute> attr = accountNotifer.addAttribute(widget.account);
    showDialog(
        context: context,
        builder: (_) => EditAttributeWidget(
            attr: attr.values.toList()[0],
            account: widget.account,
            attrKey: attr.keys.toList()[0]));
  }

  void _onType(String? v) {
    if ((v ?? '').trim() != '') {
      accountNotifer.updateName(widget.account, v!);
    }
  }

  IconButton _button(IconData icon, VoidCallback function) => IconButton(
        color: Colors.black, onPressed: function, icon: Icon(icon));

  void _showDeleteDialog() {
    final TextStyle style = TextStyle(color: widget.account.color);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor:
                  Color.lerp(Colors.white, widget.account.color, 0.2),
              title: Text(
                'Are You Sure To Delete ${widget.account.name}?',
                style: style,
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text('Cancel', style: style)),
                TextButton(
                    onPressed: () {
                      accountNotifer.deleteAccount(widget.account);
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => Consumer(
                                  builder: (BuildContext context, Object? accountNot, _) =>
                                      const AccountsPage())),
                          (_) => false);
                    },
                    child: Text('Delete', style: style))
              ],
            ));
  }

  InkWell _colorButton() => InkWell(
      onTap: _showColorPicker,
      child: Container(
        height: 20,
        width: 20,
        // margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            border: const Border.fromBorderSide(
                BorderSide(width: 3)),
            color: widget.account.color,
            borderRadius: const BorderRadius.all(Radius.circular(999))),
      ),
    );

  void _showColorPicker() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: SingleChildScrollView(
                child: ColorPicker(
                    pickerColor: widget.account.color,
                    onColorChanged: (Color c) {
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

  Widget _section(bool isMain) => Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            spacing: 5,
            children: <Widget>[
              if (isMain) _colorButton(),
              _sectionNameWidget(isMain),
            ],
          ),
          Text(isMain ? 'Main Details' : 'Additional Details'),
          _buildSectionChildren(isMain)
        ],
      ),
    );

  Widget _sectionNameWidget(bool isMain) {
    const TextStyle style = TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
    final Color? hintColor = Color.lerp(widget.account.color, Colors.white, 0.5);
    if (isMain) {
      return Expanded(
        child: TextField(
          cursorColor: widget.account.color,
          onChanged: _onType,
          controller: accountNameCont,
          style: style,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Account Name',
              hintStyle: TextStyle(color: hintColor)),
        ),
      );
    }
    return const Text('Additional Details', style: style);
  }

  Widget _buildSectionChildren(bool isMain) => SingleChildScrollView(
        child: Column(
            spacing: isMain ? 20 : 5,
            children: _getAttributes(isMain)
                .entries
                .map((MapEntry<String, Attribute> e) => AccountAttributeWidget(
                      account: widget.account,
                      attribute: e.value,
                      name: e.key,
                      color: widget.account.color,
                      showContextMenu: true,
                    ))
                .toList()));

  Map<String, Attribute> _getAttributes(bool isMain) {
    final Map<String, Attribute> attributes = <String, Attribute>{};
    if (isMain) {
      attributes[widget.account.mainKey] = widget.account.mainAttr;
      if (widget.account.secAttr != null) {
        attributes[widget.account.secKey] = widget.account.secAttr!;
      }
      return attributes;
    }
    for (MapEntry<String, Attribute> e in widget.account.attributes.entries) {
      final AttributeType type = _getType(e.key);
      if (type == AttributeType.normal) {
        attributes[e.key] = e.value;
      }
    }
    return attributes;
  }
}

enum AttributeType { normal, main, secondary }
