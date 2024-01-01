import 'package:intl/intl.dart';

final numFormatter = NumberFormat("#,##0.00", "en_US");

String formatWithSign2Decimal(double myDouble,
    {bool displayPositiveSign = false, String symbol = ''}) {
  String formatted = numFormatter.format(myDouble);

  // Add the positive sign if required
  if (displayPositiveSign && !formatted.startsWith('-')) {
    formatted = "+$formatted";
  }

  // If symbol is given, add it before the first number
  if (symbol != '') {
    int insertIndex =
        formatted.startsWith('-') ? 1 : (displayPositiveSign ? 1 : 0);
    formatted = formatted.substring(0, insertIndex) +
        symbol +
        formatted.substring(insertIndex);
  }

  return formatted;
}

String formatWithSign1Decimal(double myDouble) {
  return myDouble.toStringAsFixed(1);
}

String formatWithoutSign(double myDouble) {
  return numFormatter.format(myDouble.abs());
}

String compactDouble(double myDouble) {
  return myDouble.abs().toStringAsFixed(1);
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String formatDateWithHour(DateTime date) {
  return DateFormat('yyyy-MM-dd-HH').format(date);
}

DateTime parseDateWithHour(String dateString) {
  return DateFormat("yyyy-MM-dd-HH").parse(dateString);
}

DateTime parseDate(String dateString) {
  return DateFormat("yyyy-MM-dd").parse(dateString);
}
