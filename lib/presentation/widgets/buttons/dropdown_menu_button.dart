import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';

class DropdownMenuButton<CustomType> extends StatelessWidget {
  final List<CustomType> valueList;
  final String text;
  final Offset? offset;
  final ValueChanged<CustomType> onSelect;

  const DropdownMenuButton({
    super.key,
    required this.valueList,
    required this.onSelect,
    required this.text,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        position: PopupMenuPosition.under,
        offset: offset ?? const Offset(0, 0),
        onSelected: (CustomType newValue) {
          onSelect(newValue);
        },
        itemBuilder: (BuildContext context) => valueList.map((listElement) {
              return PopupMenuItem<CustomType>(
                  value: listElement, child: Text(listElement.toString()));
            }).toList(),
        child: Row(children: [
          Text(text, style: categoryHeaderTextStyle),
          const Icon(
            Ionicons.chevron_down_outline,
            color: howWhite,
            size: 16,
          ),
        ]));
  }
}
