import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:provider/provider.dart';

class UndoWidget extends StatefulWidget {
  final Color color;
  const UndoWidget({super.key, required this.color});

  @override
  State<UndoWidget> createState() => _UndoWidgetState();
}

class _UndoWidgetState extends State<UndoWidget> with TickerProviderStateMixin {
  int time = 0;
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<AccountNotifier>(context, listen: false).undo();
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Container(
        decoration: BoxDecoration(
            color: widget.color,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Undo",
                    style: TextStyle(color: Colors.white),
                  ),
                  VerticalDivider(
                    width: 5,
                  ),
                  Icon(
                    Icons.undo,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: widget.color,
              value: 1 - _animation.value,
            )
          ],
        ),
      ),
    );
  }
}

class EditAttributeWidget extends StatefulWidget {
  final Attribute attr;
  final Account account;
  final String attrKey;
  const EditAttributeWidget(
      {super.key,
      required this.attr,
      required this.account,
      required this.attrKey});

  @override
  State<EditAttributeWidget> createState() => _EditAttributeWidgetState();
}

class _EditAttributeWidgetState extends State<EditAttributeWidget> {
  late TextEditingController nameController;
  late TextEditingController valueController;
  final formKey = GlobalKey<FormState>();
  late AccountNotifier accountNotifier;

  @override
  void initState() {
    super.initState();
    accountNotifier = Provider.of(context, listen: false);
    nameController = TextEditingController(text: widget.attrKey);
    valueController = TextEditingController(text: widget.attr.value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: widget.account.color,
      content: Form(
        key: formKey,
        child: Consumer<AccountNotifier>(builder: (context, not, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                  activeColor: widget.account.color,
                  inactiveTrackColor: Colors.white,
                  inactiveThumbColor: widget.account.color,
                  title: Text(
                    "Sensitive",
                    style: TextStyle(color: widget.account.color),
                  ),
                  value: widget.attr.isSensitive,
                  onChanged: (v) {
                    not.setSensitive(widget.account, widget.attr, v);
                  }),
              _input(nameController, _attrNameValidator, false, false),
              _input(valueController, _attrValueValidator,
                  widget.attr.isSensitive, true),
            ],
          );
        }),
      ),
      actions: [
        TextButton(
            style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll(Colors.transparent),
                foregroundColor: WidgetStatePropertyAll(widget.account.color)),
            onPressed: save,
            child: const Text("Save"))
      ],
    );
  }

  String? _attrNameValidator(String? s) {
    if (widget.account.isAttributeExist(s ?? "") && s != widget.attrKey) {
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
      accountNotifier.updateValue(
          widget.account, valueController.text, widget.attr);
      accountNotifier.updateAttrKey(
          widget.account, widget.attrKey, nameController.text);
      Navigator.of(context).pop();
    }
  }

  TextFormField _input(TextEditingController controller,
      FormFieldValidator<String?> validator, bool hide, bool showRandomiser) {
    final border = UnderlineInputBorder(
        borderSide: BorderSide(color: widget.account.color, width: 1));
    final focusBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: widget.account.color, width: 3));
    return TextFormField(
      obscureText: hide,
      style: TextStyle(color: widget.account.color),
      cursorColor: widget.account.color,
      controller: controller,
      decoration: InputDecoration(
          focusedBorder: focusBorder,
          enabledBorder: border,
          suffixIcon: showRandomiser
              ? IconButton(
                  onPressed: () => _pickRandom(controller),
                  icon: Icon(
                    Icons.restart_alt_rounded,
                    color: widget.account.color,
                  ))
              : null),
      validator: validator,
    );
  }

  void _pickRandom(TextEditingController controller) {
    controller.text = Prefs().getRandomPass().create();
  }
}
