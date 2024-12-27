import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';
import 'package:provider/provider.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(account.color, Colors.white, 0.9),
      appBar: AppBar(
        title: Text(account.name),
        backgroundColor: account.color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 200,
                maxCrossAxisExtent: 250),
            children: [
              ...account.attributes.entries.map((e) {
                return AttributeWidget(
                    account: account,
                    type: _getType(e.key),
                    atr: e.value,
                    attributeKey: e.key,
                    color: account.color);
              })
            ],
          ),
        ),
      ),
    );
  }

  AttributeType _getType(String attributeKey) {
    if (attributeKey == account.mainKey) {
      return AttributeType.main;
    }
    if (attributeKey == account.secKey) {
      return AttributeType.secondary;
    }
    return AttributeType.normal;
  }
}

enum AttributeType { normal, main, secondary }

class AttributeWidget extends StatefulWidget {
  final Attribute atr;
  final String attributeKey;
  final Account account;
  final Color color;
  final AttributeType type;
  const AttributeWidget(
      {super.key,
      required this.atr,
      required this.attributeKey,
      required this.color,
      required this.type,
      required this.account});

  @override
  State<AttributeWidget> createState() => _AttributeWidgetState();
}

class _AttributeWidgetState extends State<AttributeWidget> {
  bool isSensitiveShown = false;
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: widget.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
          color: Color.lerp(Colors.white, widget.color, 0.4),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.attributeKey,
            style: TextStyle(
                color: widget.color, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Row(
            children: [
              _displayAttribute(widget.atr.isSensitive),
              if (widget.atr.isSensitive)
                IconButton(
                    color: widget.color,
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
          SwitchListTile(
              inactiveTrackColor: Colors.white,
              inactiveThumbColor: Color.lerp(Colors.white, widget.color, 0.4),
              activeColor: widget.color,
              contentPadding: const EdgeInsets.all(0),
              title: Text(
                "Sensitive",
                style: textStyle,
              ),
              value: widget.atr.isSensitive,
              onChanged: (v) {
                Provider.of<AccountNotifier>(
                  context,
                  listen: false,
                ).setSensitive(widget.atr, v);
              }),
          Row(
            children: [
              _checkButton("Main", widget.type == AttributeType.main),
              const VerticalDivider(
                width: 5,
              ),
              _checkButton("Secondary", widget.type == AttributeType.secondary)
            ],
          )
        ],
      ),
    );
  }

  Text _displayAttribute(bool isSensitive) {
    String txt;
    if (isSensitiveShown || !widget.atr.isSensitive) {
      txt = widget.atr.value;
    } else {
      txt = "".padLeft(widget.atr.value.length, "*");
    }
    return Text(
      txt,
      style: TextStyle(color: widget.color),
    );
  }

  Widget _checkButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border:
              Border.fromBorderSide(BorderSide(width: 1, color: widget.color)),
          color: isActive
              ? widget.color
              : Color.lerp(Colors.white, widget.color, 0.1)),
      child: Text(
        text,
        style: TextStyle(color: isActive ? Colors.white : widget.color),
      ),
    );
  }
}
