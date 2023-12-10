import 'package:flutter/material.dart';

import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';

abstract class TransactionButton extends StatelessWidget {
  final String ctaPrimary;
  final bool enabled;
  final GestureTapCallback onTap;
  final Color enabledColor;
  final Color disabledColor;

  const TransactionButton({
    super.key,
    required this.ctaPrimary,
    required this.enabled,
    required this.onTap,
    required this.enabledColor,
    required this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 48,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return disabledColor;
              }
              return enabledColor;
            },
          ),
        ),
        onPressed: enabled ? () => onTap() : null,
        child: Text(ctaPrimary, style: primaryButtonTextStyle),
      ),
    );
  }
}

class SoldButton extends TransactionButton {
  const SoldButton({
    super.key,
    required super.enabled,
    required super.onTap,
  }) : super(
          ctaPrimary: "Sold",
          enabledColor: red,
          disabledColor: disabledRed,
        );
}

class BoughtButton extends TransactionButton {
  const BoughtButton({
    super.key,
    required super.enabled,
    required super.onTap,
  }) : super(
          ctaPrimary: "Bought",
          enabledColor: green,
          disabledColor: disabledGreen,
        );
}
