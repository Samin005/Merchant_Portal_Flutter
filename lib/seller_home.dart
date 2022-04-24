import 'package:flutter/material.dart';

import 'main.dart';
import 'seller_profile.dart';
import 'category.dart';
import 'item_details.dart';
import 'order_history.dart';

import 'models/item.dart';
import 'models/order.dart';

import 'service/seller_service.dart';
import 'service/shared_service.dart';
import 'service/category_service.dart';
import 'service/item_service.dart';
import 'service/order_service.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  late Future<List<Category>> futureCategories;
  late Future<List<Item>> futureItems;
  late Future<List<OrderHistory>> futureOrderHistories;

  final ScrollController _firstController = ScrollController();
  final _newItemNameController = TextEditingController();
  String _newItemDropdownValue =
      categories.firstWhere((c) => c.isVisible).categoryName;
  final _newItemDescriptionController = TextEditingController();
  final _newItemPriceController = TextEditingController();
  final RegExp priceRegex = RegExp(r'^[0-9]\d*\.?\d*$');
  List<bool> addItemMask = [false, false, false, false];
  bool _itemAscending = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    futureCategories = getAllCategories();
    futureItems = getAllItems();
    futureOrderHistories = getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    updateVisibleCategories();

    if (currentItems.isEmpty) {
      currentItems = items.where((e) => e.isVisible).toList();
      updateCurrentCategory('#All items');
    }
    _itemAscending
        ? currentItems.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()))
        : currentItems.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    String itemSearchQuery = "";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(
                    _handleItemDeleteOnTap,
                    _handleItemEditOnTap,
                    priceRegex,
                  ),
                  query: itemSearchQuery,
                );
              },
              icon: const Icon(Icons.search_sharp),
            ),
          ),
        ],
      ),
      drawer: appDrawerSeller(context), // a drawer menu
      body: FutureBuilder(
        builder: (context, snapshotCategory) {
          if (snapshotCategory.hasData == false) {
            return const CircularProgressIndicator();
          }
          return FutureBuilder(
            builder: (context, snapshotItem) {
              if (snapshotItem.hasData == false) {
                return const CircularProgressIndicator();
              }
              return FutureBuilder(
                builder: (context, snapshotOrderHistory) {
                  if (snapshotOrderHistory.hasData == false) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          color: Colors.blue[100],
                          height: 60.0,
                          width: double.infinity,
                          child: ListTile(
                            title: const Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  padding: const EdgeInsets.only(right: 2.0),
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CategoryPage(
                                          title: "Category Editor",
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: const Icon(Icons.border_color),
                                  iconSize: 24,
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: (() {
                                    setState(() {
                                      categoryAscending = !categoryAscending;
                                    });
                                  }),
                                  icon: Icon(
                                    categoryAscending
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: Scrollbar(
                                isAlwaysShown: true,
                                controller: _firstController,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    controller: _firstController,
                                    itemCount: visibleCategoryNames.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return buildCategoryCard(
                                          context,
                                          visibleCategoryNames[index],
                                          items,
                                          getItemsOfTheCategory(
                                              visibleCategoryNames[index]),
                                          _handleCategoryOnTap);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                color: Colors.blue[100],
                                height: 60.0,
                                width: double.infinity,
                                child: ListTile(
                                  title: const Text(
                                    'Item',
                                    style: TextStyle(
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: (() {
                                        setState(() {
                                          _itemAscending = !_itemAscending;
                                        });
                                      }),
                                      icon: Icon(
                                        _itemAscending
                                            ? Icons.arrow_drop_up_sharp
                                            : Icons.arrow_drop_down_sharp,
                                        size: 50,
                                      )),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                itemCount: currentItems.length,
                                // all items or items of clicked category
                                itemBuilder: (BuildContext context, int index) {
                                  return buildItemCard(
                                    context,
                                    currentItems[index],
                                    _handleItemDeleteOnTap,
                                    _handleItemEditOnTap,
                                    priceRegex,
                                    "sellerHome",
                                    "",
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                future: futureOrderHistories,
              );
            },
            future: futureItems,
          );
        },
        future: futureCategories,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: FloatingActionButton.extended(
          onPressed: (() {
            showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  title: const Text("Add New Item"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            controller: _newItemNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              labelText: "Item name",
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                              ),
                              child: DropdownButton<String>(
                                focusNode: FocusNode(canRequestFocus: false),
                                dropdownColor: Colors.blue,
                                focusColor: Colors.grey,
                                value: _newItemDropdownValue,
                                icon: const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.black,
                                ),
                                elevation: 0,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                underline: Container(
                                  height: 2,
                                  // color: Colors.black,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _newItemDropdownValue = newValue!;
                                  });
                                },
                                items: visibleCategories
                                    .where((c) => c.isVisible)
                                    .map((e) => e.categoryName)
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            controller: _newItemDescriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                              labelText: "Item description",
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: _newItemPriceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                            prefix: Text("CAD\$"),
                            labelText: "Item price",
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => {
                        _newItemNameController.text = '',
                        _newItemDropdownValue = visibleCategories
                            .firstWhere((c) => c.isVisible)
                            .categoryName,
                        _newItemDescriptionController.text = '',
                        _newItemPriceController.text = '',
                        Navigator.pop(context),
                      },
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () {
                        addItemMask[0] = (_newItemNameController.text
                                .trim()
                                .replaceAll(RegExp(' +'), ' ') !=
                            "");
                        addItemMask[1] =
                            true; // default true as all category is active
                        addItemMask[2] =
                            true; // default true as description can be empty
                        addItemMask[3] = priceRegex.hasMatch(
                                _newItemPriceController.text.trim()) &&
                            double.parse(_newItemPriceController.text.trim()) >
                                0;
                        bool _addItemIsReady = (addItemMask[0] &&
                            addItemMask[1] &&
                            addItemMask[2] &&
                            addItemMask[3]);
                        _addItemIsReady
                            ? {
                                setState(() {
                                  if (items.any((e) =>
                                      (e.isVisible) &&
                                      (e.name.toLowerCase() ==
                                          _newItemNameController.text
                                              .trim()
                                              .replaceAll(RegExp(' +'), ' ')
                                              .toLowerCase()))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Add item failed as item already exists.\nPlease use a different item name.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                  } else {
                                    newItem(Item(
                                      "",
                                      convertToTitleCase(_newItemNameController
                                          .text
                                          .trim()
                                          .replaceAll(RegExp(' +'), ' ')),
                                      _newItemDescriptionController.text
                                          .trim()
                                          .replaceAll(RegExp(' +'), ' '),
                                      "images/no_image_available.png",
                                      categories
                                          .firstWhere((c) =>
                                              (c.isVisible) &&
                                              (c.categoryName.toLowerCase() ==
                                                  _newItemDropdownValue
                                                      .toLowerCase()))
                                          .categoryID,
                                      double.parse(double.parse(
                                              _newItemPriceController.text
                                                  .trim())
                                          .toStringAsFixed(2)),
                                      0,
                                      currentSeller!.userID,
                                      0,
                                      0,
                                      [],
                                      true,
                                    ));
                                    updateCurrentItems(items, currentCategory);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          'Item "${convertToTitleCase(_newItemNameController.text.trim().replaceAll(RegExp(' +'), ' '))}" is added',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                    _newItemNameController.clear();
                                    _newItemDropdownValue = visibleCategories
                                        .firstWhere((c) => c.isVisible)
                                        .categoryName;
                                    _newItemDescriptionController.clear();
                                    _newItemPriceController.clear();
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SellerHome(
                                            title:
                                                'Merchant Portal for Seller'),
                                      ),
                                    );
                                  }
                                }),
                              }
                            : {
                                errorMsg =
                                    'Cannot add item, please check item info:\n',
                                if (!addItemMask[0])
                                  {
                                    errorMsg =
                                        errorMsg + 'Please enter item name;\n'
                                  },
                                if (_newItemPriceController.text.isEmpty)
                                  {
                                    errorMsg =
                                        errorMsg + 'Please enter item price;'
                                  }
                                else if (!addItemMask[3])
                                  {
                                    errorMsg =
                                        errorMsg + 'Invalid price inputs;'
                                  },
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      errorMsg,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              };
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ),
            );
          }),
          label: const Text(
            'Add New Item',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _handleCategoryOnTap(List<Item> items, String theCategory) {
    setState(() {
      updateCurrentCategory(theCategory);
      updateCurrentItems(items, theCategory);
    });
  }

  void _handleItemDeleteOnTap(Item _item, String calledFrom, String itemQuery) {
    String tempItemName = _item.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Confirmation",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(_item.imgURL),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: 100,
                                child: Text(
                                  _item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.star,
                              size: 14.0,
                            ),
                            Text(
                              _item.rating.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '   \$' + _item.price.toStringAsFixed(2),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                getCategoryName(_item),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _item.description,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Continue deleting item?"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => setState(() {
              deleteItem(currentItems, _item.itemID);
              updateCurrentItems(items, currentCategory);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Item "$tempItemName" is deleted.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
              if (calledFrom == "sellerHome") {
                Navigator.pop(context);
              } else if (calledFrom == "itemSearch") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SellerHome(title: 'Merchant Portal for Seller'),
                  ),
                );
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(
                    _handleItemDeleteOnTap,
                    _handleItemEditOnTap,
                    priceRegex,
                  ),
                  query: itemQuery,
                );
              }
            }),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleItemEditOnTap(
    String itemID,
    List<bool> mask,
    String newName,
    String newCategory,
    String newDescription,
    double newPrice,
    String calledFrom,
    String itemQuery,
  ) {
    if (mask.any((e) => e)) {
      setState(() {
        updateItem(currentItems, itemID, mask, newName, newCategory,
            newDescription, newPrice);
        if (calledFrom == "itemSearch") {
          getAllItems().then((value) => {
                currentItems = [],
                updateCurrentItems(value, currentCategory),
              });
        }
      });
    }
  }

  List<String> getItemsOfTheCategory(String category) {
    List<String> _itemsOfTheCategory = [];

    // get list of items of the corresponding category card
    if (category == '#All items') {
      for (var elem in items.where((e) => e.isVisible)) {
        _itemsOfTheCategory.add(elem.name);
      }
    } else {
      if (items.where((ve) => ve.isVisible).any((e) =>
          e.categoryID ==
          visibleCategories
              .firstWhere((c) =>
                  (c.isVisible) &&
                  (c.categoryName.toLowerCase() == category.toLowerCase()))
              .categoryID)) {
        for (Item elem in items.where((e) => e.isVisible).where((e) =>
            e.categoryID ==
            visibleCategories
                .firstWhere((c) =>
                    (c.isVisible) &&
                    (c.categoryName.toLowerCase() == category.toLowerCase()))
                .categoryID)) {
          _itemsOfTheCategory.add(elem.name);
        }
      }
    }
    _itemsOfTheCategory.sort();
    return _itemsOfTheCategory;
  }
}

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate(
    this._handleItemDeleteOnTap,
    this._handleItemEditOnTap,
    this._priceRegex,
  );

  final Function _handleItemDeleteOnTap;
  final Function _handleItemEditOnTap;
  final RegExp _priceRegex;

  @override
  String get searchFieldLabel => 'Search Item and Category...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.blue,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
      ),
      textTheme: const TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.grey[200],
        selectionColor: Colors.grey[400],
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new,
        color: Colors.white,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = "";
            }
          },
        ),
      ];

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchItemList = query.isEmpty
        ? items.where((e) => e.isVisible).toList()
        : items
            .where((e) => e.isVisible)
            .where((e) =>
                e.name.toLowerCase().contains(query.toLowerCase()) ||
                visibleCategories
                    .firstWhere((c) => c.categoryID == e.categoryID)
                    .categoryName
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
    searchItemList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ListView.builder(
      itemCount: searchItemList.length,
      itemBuilder: (context, index) {
        return buildItemCard(
          context,
          searchItemList[index],
          _handleItemDeleteOnTap,
          _handleItemEditOnTap,
          _priceRegex,
          "itemSearch",
          query,
        );
      },
    );
  }
}

Widget buildItemCard(BuildContext context, Item _item, _handleItemDeleteOnTap,
    _handleItemEditOnTap, RegExp _priceRegex, String calledFrom, itemQuery) {
  final _itemNameController = TextEditingController(text: _item.name);
  String categoryNameOfItem = getCategoryName(_item);
  String dropdownValue = categoryNameOfItem;
  final _itemDescriptionController =
      TextEditingController(text: _item.description);
  final _itemPriceController =
      TextEditingController(text: _item.price.toStringAsFixed(2));
  bool _itemEditorChanged = false;
  List<bool> updateMask = [false, false, false, false];
  bool _itemEditorEmptyField = false;
  String errorMsg = '';

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: InkWell(
              child: Image.asset(_item.imgURL),
              onTap: () {
                // navigate to corresponding item detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetails(item: _item),
                  ),
                );
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 100,
                      child: Text(
                        _item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star,
                    size: 14.0,
                  ),
                  Text(
                    _item.rating.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '   \$' + _item.price.toStringAsFixed(2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  categoryNameOfItem,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _item.description,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Expanded(
            child: SizedBox(
              width: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 2.0),
                    onPressed: () =>
                        {_handleItemDeleteOnTap(_item, calledFrom, itemQuery)},
                    icon: const Icon(Icons.delete_forever_outlined),
                    iconSize: 18,
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 2.0),
                    onPressed: () => {
                      _itemNameController.text = _item.name,
                      _itemDescriptionController.text = _item.description,
                      _itemPriceController.text =
                          _item.price.toStringAsFixed(2),
                      showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(
                          builder: (context, setState) => AlertDialog(
                            title: const Text(
                              "Item Editor",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: TextFormField(
                                      controller: _itemNameController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(4.0),
                                          ),
                                        ),
                                        labelText: "Item name",
                                        errorText:
                                            _itemNameController.text.isEmpty
                                                ? 'Please enter item name.'
                                                : null,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: DropdownButton<String>(
                                          focusNode:
                                              FocusNode(canRequestFocus: false),
                                          dropdownColor: Colors.blue,
                                          focusColor: Colors.grey,
                                          value: dropdownValue,
                                          icon: const Icon(
                                            Icons.arrow_downward,
                                            color: Colors.black,
                                          ),
                                          elevation: 0,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          underline: Container(
                                            height: 2,
                                            // color: Colors.black,
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownValue = newValue!;
                                            });
                                          },
                                          items: visibleCategories
                                              .where((c) => c.isVisible)
                                              .map((e) => e.categoryName)
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12.0, bottom: 24.0),
                                    child: TextFormField(
                                      controller: _itemDescriptionController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(4.0),
                                          ),
                                        ),
                                        labelText: "Item description",
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: TextFormField(
                                    controller: _itemPriceController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                      ),
                                      prefix: const Text(
                                        "CAD\$",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      labelText: "Item price",
                                      errorText:
                                          _itemPriceController.text.isEmpty
                                              ? 'Please enter item name.'
                                              : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  _itemNameController.text = _item.name,
                                  dropdownValue = categoryNameOfItem,
                                  _itemDescriptionController.text =
                                      _item.description,
                                  _itemPriceController.text =
                                      _item.price.toStringAsFixed(2),
                                  Navigator.pop(context),
                                },
                                child: const Text("CANCEL"),
                              ),
                              TextButton(
                                onPressed: () {
                                  updateMask[0] = (_item.name.toLowerCase() !=
                                      _itemNameController.text
                                          .toLowerCase()
                                          .trim()
                                          .replaceAll(RegExp(' +'), ' '));
                                  updateMask[1] =
                                      (categoryNameOfItem != dropdownValue);
                                  updateMask[2] = (_item.description !=
                                      _itemDescriptionController.text
                                          .trim()
                                          .replaceAll(RegExp(' +'), ' '));
                                  updateMask[3] = !_priceRegex.hasMatch(
                                          _itemPriceController.text.trim()) ||
                                      (_item.price -
                                              double.parse(_itemPriceController
                                                  .text
                                                  .trim()) >
                                          0.005) ||
                                      (_item.price -
                                              double.parse(_itemPriceController
                                                  .text
                                                  .trim()) <
                                          -0.004) ||
                                      double.parse(_itemPriceController.text
                                              .trim()) <=
                                          0;
                                  _itemEditorChanged = updateMask[0] ||
                                      updateMask[1] ||
                                      updateMask[2] ||
                                      updateMask[3];
                                  _itemEditorEmptyField = _itemNameController
                                          .text
                                          .trim()
                                          .isEmpty ||
                                      _itemPriceController.text.trim().isEmpty;
                                  if (_itemEditorChanged) {
                                    if (_itemEditorEmptyField) {
                                      errorMsg =
                                          'Cannot add item, please check item info:\n';
                                      if (_itemNameController.text
                                          .trim()
                                          .isEmpty) {
                                        errorMsg = errorMsg +
                                            'Please enter item name;\n';
                                      }
                                      if (_itemPriceController.text
                                          .trim()
                                          .isEmpty) {
                                        errorMsg = errorMsg +
                                            'Please enter item price;';
                                      } else if (!_priceRegex.hasMatch(
                                              _itemPriceController.text
                                                  .trim()) ||
                                          double.parse(_itemPriceController.text
                                                  .trim()) <=
                                              0) {
                                        errorMsg =
                                            errorMsg + 'Invalid price inputs;';
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            errorMsg,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      );
                                    } else if (!_priceRegex.hasMatch(
                                            _itemPriceController.text.trim()) ||
                                        double.parse(_itemPriceController.text
                                                .trim()) <=
                                            0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'Invalid price inputs.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _handleItemEditOnTap(
                                          _item.itemID,
                                          updateMask,
                                          _itemNameController.text
                                              .trim()
                                              .replaceAll(RegExp(' +'), ' '),
                                          dropdownValue,
                                          _itemDescriptionController.text
                                              .trim()
                                              .replaceAll(RegExp(' +'), ' '),
                                          double.parse(
                                            _itemPriceController.text
                                                .trim()
                                                .replaceAll(RegExp(' +'), ' '),
                                          ),
                                          calledFrom,
                                          itemQuery,
                                        );

                                        getAllItems().then((value) => {
                                              currentItems = [],
                                              updateCurrentItems(
                                                  value, currentCategory),
                                              Navigator.pop(context),
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SellerHome(
                                                    title:
                                                        'Merchant Portal for Seller',
                                                  ),
                                                ),
                                              ),
                                            });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              'Item "${convertToTitleCase(_itemNameController.text.trim().replaceAll(RegExp(' +'), ' '))}" is updated',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        );
                                      });
                                    }
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Nothing to update.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    },
                    icon: const Icon(Icons.border_color),
                    iconSize: 18,
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 2.0),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetails(item: _item),
                        ),
                      ),
                    },
                    icon: const Icon(Icons.assignment_rounded),
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCategoryCard(BuildContext context, String theCategory,
    List<Item> _items, List<String> itemsOfTheCategory, _handleCategoryOnTap) {
  return GestureDetector(
    onTap: () => {
      itemsOfTheCategory.isNotEmpty
          ? _handleCategoryOnTap(items, theCategory)
          : null,
    },
    child: SizedBox(
      width: 200,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: currentCategory == theCategory ? 0 : 10,
        color: currentCategory == theCategory ? Colors.blue[500] : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                theCategory == '#All items' ? 'All items' : theCategory,
                style: const TextStyle(
                  // color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Palatino',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${itemsOfTheCategory.length} item(s): ' +
                    itemsOfTheCategory.join(", "),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget appDrawerSeller(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            'Hi, ${currentSeller?.userName}!',
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          currentAccountPictureSize: const Size(65, 65),
          currentAccountPicture: const CircleAvatar(
            child: Icon(
              Icons.person_outline_rounded,
              size: 60,
            ),
            radius: 50,
            backgroundColor: Colors.white,
          ),
          decoration: const BoxDecoration(color: Colors.blue),
          accountEmail: Text(
            currentSeller!.email,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ListTile(
          title: RichText(
            text: const TextSpan(
              children: [
                WidgetSpan(child: Icon(Icons.home)),
                TextSpan(
                  text: ' Home',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          hoverColor: Colors.blue,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerHome(
                  title: 'Merchant Portal for Seller',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: RichText(
            text: const TextSpan(
              children: [
                WidgetSpan(child: Icon(Icons.person)),
                TextSpan(
                  text: ' Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          hoverColor: Colors.blue,
          onTap: () {
            Navigator.pop(context);
            // Navigate user_profile page.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerProfile(title: 'Profile'),
              ),
            );
          },
        ),
        ListTile(
          title: RichText(
            text: const TextSpan(
              children: [
                WidgetSpan(child: Icon(Icons.history)),
                TextSpan(
                  text: ' Order History',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          hoverColor: Colors.blue,
          onTap: () {
            Navigator.pop(context);
            // Navigate shopping_history page.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderHistoryPage(
                  title: "Order History",
                  items: items,
                  categories: categories,
                ),
              ),
            );
          },
        ),
        ListTile(
          title: RichText(
            text: const TextSpan(
              children: [
                WidgetSpan(child: Icon(Icons.logout)),
                TextSpan(
                  text: ' Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          hoverColor: Colors.blue,
          onTap: () {
            Navigator.pop(context);
            // sign out current user
            signOut();
            // Navigate back to sign in screen when tapped.
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SignInForm(title: 'G5 Design Sign In'),
              ),
              (Route<dynamic> route) => false,
            );
          },
        )
      ],
    ),
  );
}
