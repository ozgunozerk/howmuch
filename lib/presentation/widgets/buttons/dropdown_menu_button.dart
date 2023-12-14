import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DropdownMenuButton<CustomType> extends StatelessWidget {
  final List<CustomType> valueList;
  final String text;
  final TextStyle textStyle;
  final ValueChanged<CustomType> onSelect;

  const DropdownMenuButton({
    super.key,
    required this.valueList,
    required this.onSelect,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        position: PopupMenuPosition.under,
        onSelected: (CustomType newValue) {
          onSelect(newValue);
        },
        itemBuilder: (BuildContext context) => valueList.map((listElement) {
              return PopupMenuItem<CustomType>(
                  value: listElement, child: Text(listElement.toString()));
            }).toList(),
        child: Row(children: [
          Text(text, style: textStyle),
          Icon(
            Ionicons.chevron_down_outline,
            color: textStyle.color,
            size: 16,
          ),
        ]));
  }
}
