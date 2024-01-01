import 'package:flutter/material.dart';

import 'colours.dart';

/// Page Text Styles
const TextStyle heading2TextStyle =
    TextStyle(fontWeight: FontWeight.w600, fontSize: 22);

const TextStyle welcomeTextStyle =
    TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: howBlack);

const TextStyle initialTextStyle = TextStyle(color: howWhite, fontSize: 20);

/// Button Text Styles
const TextStyle primaryButtonTextStyle = TextStyle(
    color: howWhite,
    fontSize: 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500);

const TextStyle secondaryButtonTextStyle = TextStyle(
    fontSize: 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: primary);

const TextStyle disabledPrimaryButtonTextStyle = TextStyle(
    color: buttonPrimaryDisabledTextColor,
    fontSize: 16,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700);

/// (Add Transaction & Optional Info) - Text Styles
const TextStyle transactionInfoTitleStyle =
    TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w500);

const TextStyle transactionInfoHeaderStyle =
    TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w300);

const TextStyle transactionInfoHintStyle =
    TextStyle(color: howDarkGrey, fontSize: 16, fontWeight: FontWeight.w300);

const TextStyle transactionInfoSecondaryTextStyle =
    TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400);

const TextStyle transactionInfoTextStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400);

const TextStyle transactionInfoAssetTypeStyle =
    TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400);

const TextStyle transactionInfoCurrencySymbolStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500);

/// AssetCard Text Styles
const TextStyle assetTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

TextStyle changeTextStyle(double change) {
  return TextStyle(
    fontSize: 13,
    color: change.isNegative ? red : green,
  );
}

/// CategoryCard Text Styles
const TextStyle categoryHeaderTextStyle =
    TextStyle(fontSize: 14, color: howWhite, fontWeight: FontWeight.w400);

const TextStyle categoryTotalAmountTextStyle =
    TextStyle(fontSize: 36, color: howWhite, fontWeight: FontWeight.w700);

const TextStyle categoryProfitDepositAmountTextStyle =
    TextStyle(fontSize: 18, color: howWhite, fontWeight: FontWeight.w600);

const TextStyle categoryProfitDepositDescriptorTextStyle = TextStyle(
    fontSize: 16,
    color: howWhite,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w300);

const TextStyle categoryRateChangeTextStyle =
    TextStyle(color: howWhite, fontSize: 16, fontWeight: FontWeight.w600);

/// Small Category Card Text Styles
const TextStyle smallCategoryHeaderTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

TextStyle smallCategoryChangeTextStyle(double change) {
  return TextStyle(
    fontSize: 14,
    color: change.isNegative ? red : green,
  );
}

/// Date Interval Chip Text Styles
TextStyle chipTextStyle(bool condition) {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: condition ? Colors.white : Colors.black,
  );
}

/// Asset List Text Styles
const TextStyle categoryNameTextStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

/// Disclaimer Text Style
const TextStyle disclaimerTextStyle =
    TextStyle(fontSize: 14, color: Colors.black);

/// Hyper-Link Text Style
const TextStyle linkTextStyle =
    TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

/// Dialog Information Text Style
const TextStyle dialogInfoStyle = TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);
