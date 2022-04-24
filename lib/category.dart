import 'package:flutter/material.dart';
import 'seller_home.dart';

import 'models/item.dart';

import 'service/item_service.dart';
import 'service/seller_service.dart';
import 'service/category_service.dart';
import 'service/shared_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final addNewCategoryNameController = TextEditingController();
  bool addNewCategoryIsChecked = true;
  bool addNewCategoryShowError = false;
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          }
          return Column(
            children: [
              Flexible(
                // flex: 4,
                child: StatefulBuilder(
                  builder: (context, setState) => GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.shortestSide < 400
                            ? 1
                            : MediaQuery.of(context).size.shortestSide < 600
                                ? 2
                                : 3,
                    childAspectRatio: 2,
                    children: List.generate(
                      visibleCategories.length,
                      (index) {
                        final Category _category = visibleCategories[index];

                        return GestureDetector(
                          onTap: () => {},
                          child: SizedBox(
                            child: Stack(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: AssetImage(_category.imageURL),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  _category.categoryName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Palatino',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  _category.isVisible
                                                      ? 'active'
                                                      : 'inactive',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Flexible(flex: 1, child: Container()),
                                          Flexible(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Visibility(
                                                visible:
                                                    _category.categoryName !=
                                                        'Uncategorized',
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 8.0,
                                                          right: 2.0,
                                                        ),
                                                        onPressed: () => {
                                                          setState(() {
                                                            _handleCategoryDeleteOnTap(
                                                                _category);
                                                          }),
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .delete_forever_outlined,
                                                        ),
                                                        iconSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8.0,
                                                                right: 2.0),
                                                        onPressed: () => {
                                                          setState(() {
                                                            _handleCategoryEditOnTap(
                                                                _category);
                                                          }),
                                                        },
                                                        icon: const Icon(
                                                          Icons.border_color,
                                                        ),
                                                        iconSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
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
                  title: const Text("Add New Category"),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: addNewCategoryNameController,
                            onChanged: (text) {
                              setState(() => addNewCategoryShowError = false);
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              labelText: "Category name",
                              errorText: addNewCategoryShowError
                                  ? addNewCategoryNameController.text.isEmpty
                                      ? 'Please enter category name'
                                      : categories.any((c) =>
                                              c.categoryName.toLowerCase() ==
                                              addNewCategoryNameController.text
                                                  .toLowerCase())
                                          ? 'Category name already used.\nPlease enter another category name'
                                          : null
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => {
                        addNewCategoryNameController.text = '',
                        addNewCategoryShowError = false,
                        Navigator.pop(context),
                      },
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        addNewCategoryShowError = true;
                        if ((addNewCategoryNameController.text.isNotEmpty) &&
                            (!categories.any((c) =>
                                (c.categoryName.toLowerCase() ==
                                    addNewCategoryNameController.text
                                        .toLowerCase()) &&
                                c.isVisible))) {
                          newCategory(addNewCategoryNameController.text,
                              addNewCategoryIsChecked = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Category "${convertToTitleCase(addNewCategoryNameController.text)}" is added.',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                          addNewCategoryNameController.text = '';
                          addNewCategoryIsChecked = true;
                          addNewCategoryShowError = false;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SellerHome(
                                  title: 'Merchant Portal for Seller'),
                            ),
                          );
                        }
                      }),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ),
            ); // showDialog();
          }),
          label: const Text(
            'Add New Category',
            style: TextStyle(
              // fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.add),
          // backgroundColor: Colors.pink,
          tooltip: 'Add new category',
        ),
      ),
    );
  } // Widget build(BuildContext context) {}

  void _handleCategoryDeleteOnTap(Category _category) {
    String tempCategoryName = _category.categoryName;
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Continue deleting category: $tempCategoryName?"),
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
              // update items to "Uncategorized" and
              // delete the category by setting isVisible=false at frontend and
              // get list of items under the category
              List<Item> toUncategorize = deleteCategory(_category);
              // Navigator.pop(context);
              // show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(days: 365),
                  backgroundColor: Colors.green,
                  content: Row(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Deleting Category")
                    ],
                  ),
                ),
              );
              if (toUncategorize.isNotEmpty) {
                // update items to "Uncategorized" at backend
                updateUncategorizedItems(toUncategorize).then((value) {
                  // update the category at backend by setting isVisible=false
                  categoryDELETE(_category).then((value1) {
                    // if the category is currently selected
                    if (currentCategory == _category.categoryName) {
                      // selected the "All items" category card if
                      updateCurrentCategory('#All items');
                    }
                    // update the list of itmes for the currnetCategory
                    updateCurrentItems(items, currentCategory);
                    getAllCategories().then((categoriesResponse) {
                      getAllItems().then((itemsResponse) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SellerHome(
                                title: 'Merchant Portal for Seller'),
                          ),
                        );
                      });
                    });
                  });
                });
              } else {
                // update items to "Uncategorized" at backend
                categoryDELETE(_category).then((value1) {
                  // if the category is currently selected
                  if (currentCategory == _category.categoryName) {
                    // selected the "All items" category card if
                    updateCurrentCategory('#All items');
                  }
                  // update the list of itmes for the currnetCategory
                  updateCurrentItems(items, currentCategory);
                  getAllCategories().then((categoriesResponse) {
                    getAllItems().then((itemsResponse) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerHome(
                              title: 'Merchant Portal for Seller'),
                        ),
                      );
                    });
                  });
                });
              }
            }),
            child: const Text("OK"),
          ),
        ],
      ),
    ); // showDialog();
  } // _handleCategoryDeleteOnTap(Category _category) {}

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  void _handleCategoryEditOnTap(Category _category) {
    final _categoryNameController =
        TextEditingController(text: _category.categoryName);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            "Edit Category",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      labelText: "Category name",
                      errorText: _categoryNameController.text.isEmpty
                          ? 'Please enter category name'
                          : (categories.any((c) =>
                                  (c.isVisible) &&
                                  (c.categoryName != _category.categoryName) &&
                                  (c.categoryName.toLowerCase() ==
                                      _categoryNameController.text
                                          .toLowerCase())))
                              ? 'Category name already used'
                              : null,
                    ),
                  ),
                ),
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
                if ((_categoryNameController.text.isNotEmpty) &&
                    (!categories.any((c) =>
                        (c.isVisible) &&
                        (c.categoryName.toLowerCase() ==
                            _categoryNameController.text.toLowerCase())))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(days: 365),
                      backgroundColor: Colors.green,
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          Text("Updating Category")
                        ],
                      ),
                    ),
                  );

                  if ((_categoryNameController.text.isNotEmpty) &&
                      (!categories.any((c) =>
                          (c.isVisible) &&
                          (c.categoryName.toLowerCase() ==
                              _categoryNameController.text.toLowerCase())))) {
                    String _name = _categoryNameController.text;
                    List<Item> tempNewItems = [];
                    bool hasCorrespondingItem = false;
                    List<Item> toInvisible = [];
                    bool currentCategoryIsSelected = false;
                    // add new category to backend database
                    postNewCategory(
                      Category(
                        "",
                        convertToTitleCase(_name),
                        'images/g5-design-logo.png',
                        true,
                      ),
                    ).then((value) {
                      // add new category to frontend
                      categories.add(value);
                      updateVisibleCategories();
                      if (items.any((e) =>
                          (e.isVisible) &&
                          (e.categoryID == _category.categoryID))) {
                        // create temp new items for the new category
                        tempNewItems =
                            createNewItemList(_category, value.categoryID);
                        hasCorrespondingItem = true;
                      }
                      // delete category and corresponding itmes at frontend
                      toInvisible =
                          updateCategory(_category, hasCorrespondingItem);
                      if (toInvisible.isNotEmpty) {
                        // delete corresponding items at backend by setting isVisible=false
                        updateUncategorizedItems(toInvisible).then((value) {
                          // delete the category at backend by setting isVisible=false
                          categoryDELETE(_category).then((value1) {
                            // if the category is currently selected
                            if (currentCategory == _category.categoryName) {
                              currentCategoryIsSelected = true;
                              // selected the "All items" category card
                              updateCurrentCategory('#All items');
                            }
                            // add new items to backend
                            postManyNewItems(tempNewItems).then((value2) {
                              // get all items from backend to frontend
                              getAllCategories().then((categoriesResponse) {
                                getAllItems().then((itemsResponse) {
                                  // if it was a selected category
                                  if (currentCategoryIsSelected) {
                                    // update currentCategory to new modified category
                                    updateCurrentCategory(
                                        convertToTitleCase(_name));
                                    // and update the list of items of the re-selected category
                                    updateCurrentItems(
                                        itemsResponse, currentCategory);
                                  }
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SellerHome(
                                        title: 'Merchant Portal for Seller',
                                      ),
                                    ),
                                  );
                                });
                              });
                            });
                          });
                        });
                      } else {
                        // delete the category at backend by setting isVisible=false
                        categoryDELETE(_category).then((value1) {
                          // if the category is currently selected
                          if (currentCategory == _category.categoryName) {
                            // selected the "All items" category card if
                            updateCurrentCategory('#All items');
                          }
                          // add new items to backend
                          updateUncategorizedItems(tempNewItems).then((value2) {
                            // add new items to frontend
                            updateCurrentItems(items, currentCategory);
                            getAllCategories().then((categoriesResponse) {
                              getAllItems().then((itemsResponse) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SellerHome(
                                        title: 'Merchant Portal for Seller'),
                                  ),
                                );
                              });
                            });
                          });
                        });
                      }
                    });
                  }
                }
              }),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    ); // showDialog();
  } // _handleCategoryEditOnTap(Category _category){}
}

List<Item> createNewItemList(Category _category, String _newCategoryID) {
  // check if there is any visible items under the category (to be deleted)
  if (items
      .any((e) => (e.isVisible) && (e.categoryID == _category.categoryID))) {
    // get the item id of the items
    List<Item> tempItems = items
        .where((e) => (e.isVisible) && (e.categoryID == _category.categoryID))
        .toList();

    // create the list of new items
    List<Item> newItems = [];
    int i = 1;
    for (Item tempItem in tempItems) {
      newItems.add(Item(
          'dummy_$i',
          tempItem.name,
          tempItem.description,
          tempItem.imgURL,
          _newCategoryID,
          tempItem.price,
          tempItem.rating,
          tempItem.sellerID,
          tempItem.liked,
          tempItem.disliked,
          tempItem.comments,
          true));
    }
    return newItems;
  } else {
    return [];
  }
}
