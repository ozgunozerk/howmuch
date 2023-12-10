import 'package:get/get.dart';

import 'package:how_much/controllers/fetch/price_tables_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/util/parsing.dart';

class CurrencyController extends GetxController {
  final priceController = Get.find<PriceTablesController>();
  final _selectedCurrency = BaseCurrency.USD.obs;

  String get selectedCurrency {
    return _selectedCurrency.value.name;
  }

  set selectedCurrency(String newValue) {
    final BaseCurrency newCurrency =
        BaseCurrency.values.firstWhere((currency) => currency.name == newValue);
    _selectedCurrency.value = newCurrency;
  }

  List<String> getBaseCurrencies() {
    return BaseCurrency.values.map((currency) => currency.name).toList();
  }

  String get getCurrencySymbol {
    switch (_selectedCurrency.value) {
      case BaseCurrency.USD:
        return "\$";
      case BaseCurrency.TRY:
        return "₺";
      case BaseCurrency.EUR:
        return "€";
      case BaseCurrency.BTC:
        return "₿";
    }
  }

  double get getCurrencyConversionRate {
    switch (_selectedCurrency.value) {
      case BaseCurrency.USD:
        return 1;
      case BaseCurrency.TRY:
        return priceController.getPriceForAsset(AssetType.forex, "TRY")!;
      case BaseCurrency.EUR:
        return priceController.getPriceForAsset(AssetType.forex, "EUR")!;
      case BaseCurrency.BTC:
        return 1 /
            priceController.getPriceForAsset(AssetType.crypto, "bitcoin")!;
    }
  }

  String displayCurrencyWithoutSign(double value) {
    return formatWithoutSign(value * getCurrencyConversionRate) +
        getCurrencySymbol;
  }

  String displayCurrencyWithSign2Decimals(double value) {
    return formatWithSign2Decimal(value * getCurrencyConversionRate) +
        getCurrencySymbol;
  }
}
