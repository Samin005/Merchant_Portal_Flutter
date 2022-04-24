import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/user.dart';
import '../service/item_service.dart';
import '../service/category_service.dart';
import '../service/shared_service.dart';

User? currentSeller;

String currentCategory = '#All items';
List<Item> currentItems = [];
List<Category> visibleCategories = [];
List<String> visibleCategoryNames = [];
bool categoryAscending = true;

void updateCurrentSeller(User user) {
  currentSeller = user;
}

void updateVisibleCategories() {
  visibleCategories = categories.where((e) => e.isVisible).toList();
  visibleCategories.sort((a, b) =>
      a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
  visibleCategoryNames = visibleCategories.map((e) => e.categoryName).toList();
  categoryAscending
      ? visibleCategoryNames
          .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))
      : visibleCategoryNames
          .sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
  visibleCategoryNames.insert(0, '#All items');
  // print('UVC: $visibleCategoryNames');
}

void updateCurrentCategory(String category) {
  currentCategory = category;
  // print('UCC: $currentCategory');
}

void updateCurrentItems(List<Item> _items, String _category) {
  // print('UCI: <$_category> ${currentItems.map((e) => e.name)}');
  currentItems = [];
  if (_category == '#All items') {
    currentItems = _items.where((e) => e.isVisible).toList();
  } else {
    for (var elem in _items.where((e) =>
        (e.isVisible) &&
        (e.categoryID ==
            categories
                .firstWhere((c) =>
                    (c.isVisible) &&
                    (c.categoryName.toLowerCase() == _category.toLowerCase()))
                .categoryID))) {
      currentItems.add(elem);
    }
  }
  currentItems
      .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  debugPrint('UCI: <$_category> ${currentItems.map((e) => e.name)}');
}

List<Item> deleteCategory(Category _category) {
  // check if there is any visible items under the category (to be deleted)
  if (items
      .any((e) => (e.isVisible) && (e.categoryID == _category.categoryID))) {
    // get the item id of the items
    List<String> tempItemIDs = items
        .where((e) => (e.isVisible) && (e.categoryID == _category.categoryID))
        .map((e) => e.itemID)
        .toList();

    // get the list of items
    List<Item> toUncategorize = [];
    for (String tempItemID in tempItemIDs) {
      items.firstWhere((element) => element.itemID == tempItemID).categoryID =
          categories
              .firstWhere(
                  (element2) => element2.categoryName == 'Uncategorized')
              .categoryID;
      toUncategorize
          .add(items.firstWhere((element) => element.itemID == tempItemID));
      updateVisibleCategories();
      updateCurrentItems(items, currentCategory);
    }

    // delete the category by setting its isVisible = false
    categories
        .firstWhere((e) => e.categoryID == _category.categoryID)
        .isVisible = false;

    // return the list of corresponding items
    return toUncategorize;
  } else {
    // return an emply list of item if there is no corresponding item
    return [];
  }
}

List<Item> updateCategory(Category _category, bool _hasCorrespondingItem) {
  // check if there is any visible items under the category (to be deleted)
  if (_hasCorrespondingItem) {
    // get the item id of the items
    List<String> tempItemIDs = items
        .where((e) => (e.isVisible) && (e.categoryID == _category.categoryID))
        .map((e) => e.itemID)
        .toList();

    // get the list of items
    List<Item> toInvisible = [];
    for (String tempItemID in tempItemIDs) {
      items.firstWhere((e) => e.itemID == tempItemID).isVisible = false;
      toInvisible.add(items.firstWhere((e) => e.itemID == tempItemID));
      updateVisibleCategories();
      // updateCurrentItems(items, currentCategory);
    }

    // delete the category by setting its isVisible = false
    categories
        .firstWhere((e) => e.categoryID == _category.categoryID)
        .isVisible = false;

    // return the list of corresponding items
    return toInvisible;
  } else {
    // return an emply list of item if there is no corresponding item
    return [];
  }
}

void newCategory(String _name, bool _isVisible) {
  if ((_name.isNotEmpty) &&
      (!categories.any((c) =>
          (c.isVisible) &&
          (c.categoryName.toLowerCase() == _name.toLowerCase())))) {
    // add new category to backend database
    postNewCategory(
      Category(
        "",
        convertToTitleCase(_name),
        'images/g5-design-logo.png',
        _isVisible,
      ),
    )
        .then((value) => {
              categories.add(value),
              updateVisibleCategories(),
            })
        .onError((error, stackTrace) => {debugPrint('error: $error')});
  }
}

String getCategoryName(Item _item) {
  return categories
      .firstWhere((c) => (c.isVisible) && (c.categoryID == _item.categoryID))
      .categoryName;
}

void setUncategorizedItems(Category _category) {
  if (items
      .any((e) => (e.isVisible) && (e.categoryID == _category.categoryID))) {
    // get the item id of the items
    List<String> tempItemIDs = items
        .where((e) => (e.isVisible) && (e.categoryID == _category.categoryID))
        .map((e) => e.itemID)
        .toList();

    // update the item category to "Uncategorized"
    for (String tempItemID in tempItemIDs) {
      items.firstWhere((element) => element.itemID == tempItemID).categoryID =
          categories
              .firstWhere(
                (element2) => element2.categoryName == "Uncategorized",
              )
              .categoryID;
      updateVisibleCategories();
      updateCurrentItems(items, currentCategory);
    }
  }

  // delete the category by setting its isVisible = false
  categories.firstWhere((e) => e.categoryID == _category.categoryID).isVisible =
      false;
  updateVisibleCategories();
  updateCurrentItems(items, currentCategory);
}

void deleteItem(List<Item> currentItems, String _itemID) {
  // to delete an item, set isVisible = false for the item
  items.firstWhere((e) => e.itemID == _itemID).isVisible = false;

  // remove item from currentItems if it is in currentItems (update page)
  if (currentItems.any((e) => e.itemID == _itemID)) {
    currentItems.removeWhere((e) => e.itemID == _itemID);
  }

  // update backend database
  updateItemPUT(items.firstWhere((e) => e.itemID == _itemID));
}

void updateItem(
  List<Item> currentItems,
  String _itemID,
  List<bool> updateMask,
  String newName,
  String newCategory,
  String newDescription,
  double newPrice,
) {
  // get item from items for update
  Item? tempItem =
      items.firstWhere((e) => (e.isVisible) && (e.itemID == _itemID));

  // create a temp new item
  Item? tempNewItem = Item(
    '',
    updateMask[0] ? convertToTitleCase(newName) : tempItem.name,
    updateMask[2] ? newDescription : tempItem.description,
    tempItem.imgURL,
    updateMask[1]
        ? categories
            .firstWhere((c) =>
                (c.isVisible) &&
                (c.categoryName.toLowerCase() == newCategory.toLowerCase()))
            .categoryID
        : tempItem.categoryID,
    updateMask[3] ? newPrice : tempItem.price,
    tempItem.rating,
    tempItem.sellerID,
    tempItem.liked,
    tempItem.disliked,
    tempItem.comments,
    tempItem.isVisible,
  );

  // delete old item
  deleteItem(currentItems, _itemID);

  // add new item to backend database
  postNewItem(tempNewItem);
}

void newItem(Item tempNewItem) {
  // add new item to backend database
  postNewItem(tempNewItem).then((value) => {
        // debugPrint('data: ${value.toJson()}'),
        // add new item to items
        items.add(value),
        updateVisibleCategories(),
        updateCurrentItems(items, currentCategory),
      });
  // .onError((error, stackTrace) => {debugPrint(error.toString())});
}

void signOut() {
  currentSeller = null;
  currentCategory = '#All items';
  currentItems = [];
  visibleCategories = [];
  visibleCategoryNames = [];
}
