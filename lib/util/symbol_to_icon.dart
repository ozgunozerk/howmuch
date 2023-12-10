import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cryptofont/cryptofont.dart';
import 'package:ionicons/ionicons.dart';

import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/util/helper_funcs.dart';

Widget assetIdToIcon(String assetId, AssetType assetType) {
  switch (assetType) {
    case AssetType.crypto:
      String assetSymbol = cryptoIdToSymbol(assetId);
      IconData? iconData = CryptoFontIcons.fromSymbol(assetSymbol);
      if (iconData == null) {
        return generateIconWithInitial(assetSymbol);
      } else {
        return Icon(iconData);
      }
    case AssetType.nasdaq:
      // TODO: find an icon set for nasdaq
      return generateIconWithInitial(assetId);

    case AssetType.forex:
      // TODO: find an icon set for forex
      return generateIconWithInitial(assetId);

    case AssetType.bist:
      // TODO: find an icon set for crypto
      return generateIconWithInitial(assetId);
  }
}

CircleAvatar generateIconWithInitial(String assetId) {
  return CircleAvatar(
    radius: 12,
    backgroundColor:
        darkPastelColors[Random().nextInt(darkPastelColors.length)],
    child: Text(
      assetId[0].toUpperCase(), // Take the first character of the assetSymbol
      style: const TextStyle(color: Colors.white, fontSize: 13),
    ),
  );
}

Widget categoryIcon(Category category, Color color) {
  // take `category` name as parameter
  // try to create `AssetType` from the name
  // if failed: use avatar with the initial
  // else: match it against predefined symbols

  AssetType? assetType;
  try {
    assetType = AssetTypeHelper.fromString(
        category); // handle error here, or don't return error from `fromString`
  } catch (_) {
    return generateIconWithInitial(category[0]);
  }
  switch (assetType) {
    case AssetType.crypto:
      return Icon(
        Ionicons.logo_bitcoin,
        color: color,
      );
    case AssetType.nasdaq:
      return Icon(
        Ionicons.logo_apple,
        color: color,
      );
    case AssetType.forex:
      return Icon(
        Ionicons.logo_yen,
        color: color,
      );
    case AssetType.bist:
      return Icon(
        Ionicons.cash,
        color: color,
      );
  }
}
