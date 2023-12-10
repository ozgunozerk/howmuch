import 'package:flutter/material.dart';

import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';

class GenericButton extends StatelessWidget {
  final String cta;
  final bool enabled;
  final GestureTapCallback onTap;
  final bool small;
  final TextStyle textStyle;
  final Color enabledColor;
  final Color disabledColor;

  const GenericButton({
    super.key,
    required this.cta,
    required this.enabled,
    required this.onTap,
    required this.textStyle,
    required this.enabledColor,
    required this.disabledColor,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: small ? 160 : 326,
        height: small ? 48 : 62,
        child: FilledButton(
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
          child: Text(cta, style: textStyle),
        ));
  }
}

class PrimaryButton extends GenericButton {
  const PrimaryButton(
      {super.key,
      required super.cta,
      required super.enabled,
      required super.onTap,
      super.small = false})
      : super(
          textStyle: primaryButtonTextStyle,
          enabledColor: primary,
          disabledColor: howGrey,
        );
}

class SecondaryButton extends GenericButton {
  const SecondaryButton(
      {super.key,
      required super.cta,
      required super.enabled,
      required super.onTap,
      super.small = false})
      : super(
          textStyle: secondaryButtonTextStyle,
          enabledColor: lightPrimary,
          disabledColor: howGrey,
        );
}
