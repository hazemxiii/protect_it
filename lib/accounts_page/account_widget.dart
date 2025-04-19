import 'package:flutter/material.dart';
import 'package:protect_it/account_details/account_details.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/attribute.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/global.dart';
import 'package:provider/provider.dart';

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
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Color.lerp(Colors.white, Colors.black, 0.06),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              CircleAvatar(
                backgroundColor: widget.account.color,
                radius: 5,
              ),
              Expanded(
                child: Text(
                  widget.account.name,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountAttributeWidget(
                  attribute: widget.account.mainAttr,
                  color: widget.account.color,
                  name: widget.account.mainKey),
              if (widget.account.secAttr != null)
                AccountAttributeWidget(
                    attribute: widget.account.secAttr!,
                    color: widget.account.color,
                    name: widget.account.secKey),
            ],
          ),
          InkWell(
              onTap: _openDetails,
              child: Row(
                children: [
                  Expanded(
                    child: Text("Show details →",
                        style: TextStyle(color: widget.account.color),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              )),
        ],
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
}

class AccountAttributeWidget extends StatefulWidget {
  final Attribute attribute;
  final String name;
  final Color color;
  const AccountAttributeWidget(
      {super.key,
      required this.attribute,
      required this.name,
      required this.color});

  @override
  State<AccountAttributeWidget> createState() => _AccountAttributeWidgetState();
}

class _AccountAttributeWidgetState extends State<AccountAttributeWidget> {
  @override
  void initState() {
    super.initState();
    isHidden = widget.attribute.isSensitive;
  }

  bool isHidden = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                isHidden
                    ? "".padLeft(widget.attribute.value.length, "•")
                    : widget.attribute.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.attribute.isSensitive)
          InkWell(
            onTap: () => setState(() => isHidden = !isHidden),
            child: Icon(isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
          ),
        const SizedBox(width: 10),
        InkWell(
            onTap: () => copy(context, widget.color, widget.attribute.value),
            child: const Icon(Icons.copy_rounded, size: 17)),
      ],
    );
  }
}
