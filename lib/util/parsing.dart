import 'package:intl/intl.dart';

final numFormatter = NumberFormat("#,###.##", "en_US");

String formatWithSign2Decimal(double myDouble) {
  if (myDouble == 0) {
    return '0.00';
  }

  String formatted = numFormatter.format(myDouble);

  // Add the leading zero if not present
  // negative case
  if (formatted.startsWith('-.')) {
    formatted = formatted.replaceFirst('-.', '-0.');
  }
  // positive case
  if (formatted.startsWith('.')) {
    formatted = formatted.replaceFirst('.', '0.');
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
