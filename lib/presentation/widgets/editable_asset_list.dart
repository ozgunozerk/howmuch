import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:how_much/controllers/user_assets_controller.dart';
import 'package:how_much/custom_types.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/presentation/widgets/cards/editable_asset_card.dart';
import 'package:how_much/presentation/widgets/drawer_contents/edit_asset.dart';
import 'package:how_much/util/helper_funcs.dart';

class EditableAssetList extends StatelessWidget {
  final Map<Category, Map<AssetUid, Asset>> categoryAssetMap;

  const EditableAssetList({
    super.key,
    required this.categoryAssetMap,
  });

  @override
  Widget build(BuildContext context) {
    final UserAssetsController userAssetsController =
        Get.find<UserAssetsController>();

    return ListView.separated(
      itemCount: categoryAssetMap.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 48),
      ),
      itemBuilder: (context, index) {
        Category category = categoryAssetMap.keys.elementAt(index);
        List<MapEntry<AssetUid, Asset>> categoryAssets =
            categoryAssetMap[category]!
                .entries
                .where((assetTypeIDTuple) => assetTypeIDTuple.value.amount != 0)
                .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController controller =
                            TextEditingController();

                        return _categoryNameInputDialog(controller,
                            userAssetsController, context, category);
                      },
                    );
                  },
                  child: Text(
                    category.capitalize!,
                    style: categoryNameTextStyle,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Make sure to match the borderRadius of your Material
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 2, // Blur radius
                      offset: const Offset(0, 1), // X,Y offsets of the shadow
                    ),
                  ],
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  child: DragTarget<DraggableAsset>(
                    builder: (context, candidateData, rejectedData) {
                      return Column(
                        children: _buildAssetItems(
                          userAssetsController,
                          category,
                          categoryAssets,
                          context,
                        ),
                      );
                    },
                    onAcceptWithDetails: (dropped) {
                      // Handle the asset drop here
                      // You can use userAssetsController methods to update categories
                      // For example:
                      userAssetsController.changeAssetCategory(
                        dropped.data.assetId,
                        dropped.data.assetType,
                        dropped.data.category,
                        category,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _categoryNameInputDialog(
    TextEditingController controller,
    UserAssetsController userAssetsController,
    BuildContext context,
    Category category) {
  return AlertDialog(
    title: const Text("Enter a new name for the category"),
    content: categoryInput(controller, userAssetsController, true),
    actions: <Widget>[
      TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      Obx(() => TextButton(
            onPressed: userAssetsController.categoryNameValid
                ? () {
                    String newCategoryName = controller.text;
                    userAssetsController.updateCategoryName(
                        category, newCategoryName);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text("OK"),
          )),
    ],
  );
}

List<Widget> _buildAssetItems(
  UserAssetsController userAssetsController,
  Category category,
  List<MapEntry<AssetUid, Asset>> categoryAssets,
  BuildContext context,
) {
  if (categoryAssets.isEmpty) {
    return [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("this category will be deleted on save if left empty"),
      )
    ];
  }

  return List.generate(categoryAssets.length, (assetIndex) {
    MapEntry<AssetUid, Asset> entry = categoryAssets[assetIndex];
    String assetId = entry.key.item2;
    AssetType assetType = entry.key.item1;
    Asset assetData = entry.value;

    BorderRadius borderRadius =
        calculateBorderRadius(categoryAssets.length, assetIndex);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            bottomSheetModalInvoker(
                context,
                AssetEdit(
                  category: category,
                  assetType: assetType,
                  assetId: assetId,
                  currentAmount: assetData.amount,
                ),
                0.90,
                true);
          },
          child: LongPressDraggable<DraggableAsset>(
            data: DraggableAsset(category, assetType, assetId),
            feedback: Material(
              child: EditableAssetCard(
                assetId: assetId,
                amount: assetData.amount,
                value: assetData.value,
                assetType: assetType,
                borderRadius: borderRadius,
              ),
            ),
            childWhenDragging: const SizedBox(),
            child: EditableAssetCard(
              assetId: assetId,
              amount: assetData.amount,
              value: assetData.value,
              assetType: assetType,
              borderRadius: borderRadius,
            ),
          ),
        ),
        if (assetIndex !=
            categoryAssets.length -
                1) // Add divider for each item except the last one
          const Divider(
            height: 1,
            thickness: 0.5,
            color: howLightGrey,
          ),
      ],
    );
  });
}

class DraggableAsset {
  final Category category;
  final AssetType assetType;
  final AssetId assetId;

  DraggableAsset(this.category, this.assetType, this.assetId);
}
