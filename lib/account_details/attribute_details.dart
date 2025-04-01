import 'package:flutter/material.dart';
import 'package:protect_it/account_details/account_details.dart';
import 'package:protect_it/account_details/attribute_custom_widgets.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/global.dart';
import 'package:provider/provider.dart';

class AttributeWidget extends StatefulWidget {
  final Attribute attr;
  final String attributeKey;
  final Account account;
  final AttributeType type;
  const AttributeWidget(
      {super.key,
      required this.attr,
      required this.attributeKey,
      required this.type,
      required this.account});

  @override
  State<AttributeWidget> createState() => _AttributeWidgetState();
}

class _AttributeWidgetState extends State<AttributeWidget> {
  late final AccountNotifier accountProvider;
  late TextEditingController nameController;
  late TextEditingController valueController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    valueController.dispose();
  }

  bool isSensitiveShown = false;
  @override
  Widget build(BuildContext context) {
    nameController = TextEditingController(text: widget.attributeKey);
    valueController = TextEditingController(text: widget.attr.value);
    TextStyle textStyle = TextStyle(color: widget.account.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: Color.lerp(Colors.white, widget.account.color, 0.4),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  color: widget.account.color,
                  onPressed: () =>
                      copy(context, widget.account.color, widget.attr.value),
                  icon: const Icon(Icons.copy)),
              IconButton(
                  color: widget.account.color,
                  onPressed: _deleteAttribute,
                  icon: const Icon(Icons.delete_outline_rounded)),
              IconButton(
                  color: widget.account.color,
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit))
            ],
          ),
          Flexible(
            child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              widget.attributeKey,
              style: TextStyle(
                  color: widget.account.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          Row(
            children: [
              _displayAttribute(widget.attr.isSensitive),
              if (widget.attr.isSensitive)
                IconButton(
                    color: widget.account.color,
                    onPressed: _toggleShowSensitive,
                    icon: Icon(isSensitiveShown
                        ? Icons.visibility
                        : Icons.visibility_off))
            ],
          ),
          _switch(textStyle),
          Row(
            children: [
              _checkButton(true, widget.type == AttributeType.main),
              const VerticalDivider(
                width: 5,
              ),
              _checkButton(false, widget.type == AttributeType.secondary)
            ],
          )
        ],
      ),
    );
  }

  void _deleteAttribute() {
    if (accountProvider.deleteAttribute(widget.account, widget.attributeKey)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: const Duration(seconds: 10),
            backgroundColor:
                Color.lerp(Colors.white, widget.account.color, 0.1),
            content: UndoWidget(
              color: widget.account.color,
            )),
      );
    }
  }

  Widget _displayAttribute(bool isSensitive) {
    String txt;
    if (isSensitiveShown || !widget.attr.isSensitive) {
      txt = widget.attr.value;
    } else {
      txt = "".padLeft(widget.attr.value.length, "*");
    }

    return Expanded(
      child: Text(
        overflow: TextOverflow.ellipsis,
        txt,
        style: TextStyle(color: widget.account.color),
      ),
    );
  }

  void _toggleShowSensitive() {
    setState(() {
      isSensitiveShown = !isSensitiveShown;
    });
  }

  Widget _checkButton(bool isMain, bool isActive) {
    return InkWell(
      onTap: () {
        _checkButtonClick(isMain, widget.account, widget.attributeKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.fromBorderSide(
                BorderSide(width: 1, color: widget.account.color)),
            color: isActive
                ? widget.account.color
                : Color.lerp(Colors.white, widget.account.color, 0.1)),
        child: Text(
          isMain ? "Main" : "Secondary",
          style:
              TextStyle(color: isActive ? Colors.white : widget.account.color),
        ),
      ),
    );
  }

  void _checkButtonClick(bool isMain, Account account, String key) {
    if (isMain) {
      accountProvider.setMain(account, key);
    } else {
      accountProvider.setSec(account, key);
    }
  }

  SwitchListTile _switch(TextStyle textStyle) {
    return SwitchListTile(
        inactiveTrackColor: Colors.white,
        inactiveThumbColor: Color.lerp(Colors.white, widget.account.color, 0.4),
        activeColor: widget.account.color,
        contentPadding: const EdgeInsets.all(0),
        title: Text(
          "Sensitive",
          style: textStyle,
        ),
        value: widget.attr.isSensitive,
        onChanged: (v) {
          Provider.of<AccountNotifier>(
            context,
            listen: false,
          ).setSensitive(widget.account, widget.attr, v);
        });
  }

  void _showEditDialog() {
    showDialog(
        context: context,
        builder: (_) => EditAttributeWidget(
            attr: widget.attr,
            account: widget.account,
            attrKey: widget.attributeKey));
  }
}
