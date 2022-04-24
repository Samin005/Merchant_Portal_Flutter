import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'main.dart';
import 'user_profile.dart';
import 'item_details.dart';
import 'shopping_history.dart';
import 'shopping_cart.dart';

import 'service/user_service.dart';
import 'service/category_service.dart';
import 'service/item_service.dart';
import 'service/order_service.dart';
import 'service/cart_service.dart';

import 'models/item.dart';
import 'models/order.dart';

class UserHome extends StatefulWidget {
  const UserHome({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final ScrollController _firstController = ScrollController();
  late Future<List<Category>> futureCategories;
  late Future<List<Item>> futureItems;
  late Future<List<OrderHistory>> futureOrderHistories;

  @override
  void initState() {
    super.initState();
    futureCategories = getAllCategories();
    futureItems = getAllItems();
    futureOrderHistories = getAllOrders();
  }

  bool _itemAscending = true;
  bool _categoryAscending = true;
  String errorMsg = '';

  @override
  Widget build(BuildContext context) {
    updateVisibleCategories();
    _categoryAscending
        ? visibleCategoryNames
            .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))
        : visibleCategoryNames
            .sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
    visibleCategoryNames.insert(0, '#All items');

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
                  delegate: MySearchDelegate(),
                  query: itemSearchQuery,
                );
              },
              icon: const Icon(Icons.search_sharp),
            ),
          ),
        ],
      ),
      drawer: appDrawer(context), // a drawer menu
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          }
          return FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              }
              return FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
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
                            trailing: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: (() {
                                setState(() {
                                  _categoryAscending = !_categoryAscending;
                                });
                              }),
                              icon: Icon(
                                _categoryAscending
                                    ? Icons.arrow_drop_up_sharp
                                    : Icons.arrow_drop_down_sharp,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 150,
                              // flex: 1,
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
                                      return buildUserCategoryCard(
                                          context,
                                          visibleCategoryNames[index],
                                          items,
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: buildItemGridView(context, currentItems),
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
    );
  }

  void _handleCategoryOnTap(List<Item> items, String theCategory) {
    setState(() {
      updateCurrentCategory(theCategory);
      updateCurrentItems(items, theCategory);
    });
  }
}

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate();

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
            .where((ve) => ve.isVisible)
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
    return buildItemGridView(context, searchItemList);
  }
}

Widget buildItemGridView(BuildContext context, List<Item> _searchItems) {
  return GridView.count(
    crossAxisCount: MediaQuery.of(context).size.width < 550
        ? 2
        : MediaQuery.of(context).size.width < 750
            ? 3
            : MediaQuery.of(context).size.width < 900
                ? 4
                : 5,
    childAspectRatio: 0.8,
    children: List.generate(_searchItems.length, (index) {
      final Item item = _searchItems[index];

      return Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetails(item: item),
              ),
            );
          },
          child: Column(
            children: [
              Expanded(flex: 8, child: Image.asset(item.imgURL)),
              Expanded(
                flex: 1,
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 13.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

Widget buildUserCategoryCard(BuildContext context, String theCategory,
    List<Item> _items, _handleCategoryOnTap) {
  var itemsOfTheCatigory = [];

  // get list of items of the corresponding category card
  if (theCategory == '#All items') {
    for (var elem in _items.where((e) => e.isVisible)) {
      itemsOfTheCatigory.add(elem.name);
    }
  } else {
    if (_items.where((ve) => ve.isVisible).any((e) =>
        e.categoryID ==
        visibleCategories
            .firstWhere((c) =>
                (c.isVisible) &&
                (c.categoryName.toLowerCase() == theCategory.toLowerCase()))
            .categoryID)) {
      for (Item elem in _items.where((ve) => ve.isVisible).where((e) =>
          e.categoryID ==
          visibleCategories
              .firstWhere((c) =>
                  (c.isVisible) &&
                  (c.categoryName.toLowerCase() == theCategory.toLowerCase()))
              .categoryID)) {
        itemsOfTheCatigory.add(elem.name);
      }
    }
  }
  itemsOfTheCatigory.sort();

  return GestureDetector(
    onTap: () => {
      itemsOfTheCatigory.isNotEmpty
          ? _handleCategoryOnTap(items, theCategory)
          : null,
    },
    child: SizedBox(
      width: 250,
      child: Stack(
        children: [
          Card(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    categories.any((c) => c.categoryName == theCategory)
                        ? categories
                            .firstWhere((c) => c.categoryName == theCategory)
                            .imageURL
                        : 'images/g5-design-logo.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: currentCategory == theCategory ? 5 : 30,
            color: currentCategory == theCategory
                ? Colors.transparent.withOpacity(0.3)
                : Colors.grey.withOpacity(0.6),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      theCategory == '#All items' ? 'All items' : theCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Palatino',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${itemsOfTheCatigory.length} item(s): ' +
                          itemsOfTheCatigory.join(", "),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
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
}

Widget appDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        // DrawerHeader(
        UserAccountsDrawerHeader(
          accountName: Text(
            'Hi, ${currentUser?.userName}!',
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
            currentUser!.email,
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
                builder: (context) => const UserHome(
                  title: 'G5 Online Shopping',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Badge(
                    badgeContent: Text(
                      '${cart.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: const Icon(Icons.shopping_cart),
                    showBadge: cart.isNotEmpty ? true : false,
                  ),
                ),
                const TextSpan(
                  text: ' Cart',
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
                builder: (context) => const ShoppingCart(
                  title: 'Shopping Cart',
                  itemID: '',
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
                builder: (context) => const UserProfile(title: 'Profile'),
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
                  text: ' Shopping History',
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
                builder: (context) => ShoppingHistory(
                  title: "Shopping History",
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
