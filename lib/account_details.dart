import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
        actions: [
          InkWell(
            onTap: () {
              showColorPicker(context);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  border: const Border.fromBorderSide(
                      BorderSide(width: 3, color: Colors.white)),
                  color: account.color,
                  borderRadius: const BorderRadius.all(Radius.circular(999))),
            ),
          )
        ],
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

  void showColorPicker(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: SingleChildScrollView(
                child: ColorPicker(
                    pickerColor: account.color,
                    onColorChanged: (c) {
                      Provider.of<AccountNotifier>(context, listen: false)
                          .updateColor(account, c);
                    }),
              ),
            ));
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
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit))
            ],
          ),
          Text(
            widget.attributeKey,
            style: TextStyle(
                color: widget.account.color,
                fontWeight: FontWeight.bold,
                fontSize: 20),
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

  Text _displayAttribute(bool isSensitive) {
    String txt;
    if (isSensitiveShown || !widget.attr.isSensitive) {
      txt = widget.attr.value;
    } else {
      txt = "".padLeft(widget.attr.value.length, "*");
    }
    return Text(
      txt,
      style: TextStyle(color: widget.account.color),
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
          ).setSensitive(widget.attr, v);
        });
  }

  void _showEditDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              surfaceTintColor: widget.account.color,
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _input(nameController, _attrNameValidator),
                    _input(valueController, _attrValueValidator),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Colors.transparent),
                        foregroundColor:
                            WidgetStatePropertyAll(widget.account.color)),
                    onPressed: save,
                    child: const Text("Save"))
              ],
            ));
  }

  TextFormField _input(
      TextEditingController controller, FormFieldValidator<String?> validator) {
    final border = UnderlineInputBorder(
        borderSide: BorderSide(color: widget.account.color, width: 1));
    final focusBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: widget.account.color, width: 3));
    return TextFormField(
      style: TextStyle(color: widget.account.color),
      cursorColor: widget.account.color,
      controller: controller,
      decoration:
          InputDecoration(focusedBorder: focusBorder, enabledBorder: border),
      validator: validator,
    );
  }

  String? _attrNameValidator(String? s) {
    if (widget.account.isAttributeExist(s ?? "") && s != widget.attributeKey) {
      return "Attribute Name Already Exist";
    }
    return null;
  }

  String? _attrValueValidator(String? s) {
    if ((s ?? "") == "") {
      return "Can't be an empty field";
    }
    return null;
  }

  void save() {
    if (formKey.currentState!.validate()) {
      accountProvider.updateValue(valueController.text, widget.attr);
      accountProvider.updateAttrKey(
          widget.account, widget.attributeKey, nameController.text);
      Navigator.of(context).pop();
    }
  }
}
