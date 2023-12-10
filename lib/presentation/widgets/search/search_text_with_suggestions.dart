import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';

class SearchFieldWithSuggestions extends StatelessWidget {
  final Iterable<String> Function(String pattern) suggestionsCallback;
  final void Function(String selection) onSelectedCallback;

  const SearchFieldWithSuggestions({
    super.key,
    required this.suggestionsCallback,
    required this.onSelectedCallback,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController typeAheadController = TextEditingController();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
            child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: typeAheadController,
            textAlignVertical: TextAlignVertical.center,
            textCapitalization: TextCapitalization.characters,
            autofocus: false,
            autocorrect: false,
            enableSuggestions: false,
            cursorColor: howDarkGrey,
            keyboardType: TextInputType.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
                isCollapsed: true,
                hintStyle: transactionInfoHintStyle,
                hintText: "Enter the name of the asset",
                border: InputBorder.none,
                counterText: ''),
          ),
          noItemsFoundBuilder: (BuildContext context) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  "No assets found. Are you sure the correct 'Asset Type' is selected?"),
            );
          },
          hideOnEmpty: false,
          hideSuggestionsOnKeyboardHide: true,
          minCharsForSuggestions: 1,
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
              color: lightPrimary,
              constraints: const BoxConstraints(maxWidth: 400),
              offsetX: 0,
              borderRadius: BorderRadius.circular(16)),
          suggestionsCallback: (String pattern) async {
            return suggestionsCallback(pattern);
          },
          itemBuilder: (BuildContext context, String itemData) {
            return ListTile(
              title: Text(itemData),
            );
          },
          onSuggestionSelected: (String suggestion) {
            typeAheadController.text = suggestion;
            onSelectedCallback(suggestion);
          },
        )),
      ],
    );
  }
}
