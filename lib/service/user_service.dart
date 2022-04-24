import 'dart:convert';
import 'package:http/http.dart' as http;

import 'category_service.dart';
import '../models/user.dart';
import '../service/shared_service.dart';
import '../models/item.dart';
import '../service/cart_service.dart';

User? currentUser;
List<User> users = [];

String currentCategory = '#All items';
List<Item> currentItems = [];
List<Category> visibleCategories = [];
List<String> visibleCategoryNames = [];

void updateCurrentUser(User user) {
  currentUser = user;
}

void updateVisibleCategories() {
  visibleCategories = categories.where((e) => e.isVisible).toList();
  visibleCategoryNames = visibleCategories.map((e) => e.categoryName).toList();
}

void updateCurrentCategory(String category) {
  currentCategory = category;
}

void updateCurrentItems(List<Item> _items, String _category) {
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
}

void signOut() {
  currentUser = null;
  users = [];
  currentCategory = '#All items';
  currentItems = [];
  cart = [];
  totalPrice = 0.0;
  visibleCategories = [];
  visibleCategoryNames = [];
}

Future<List<User>> getAllUsers() async {
  final response = await http.get(Uri.parse('$apiURL/user'));
  if (response.statusCode == 200) {
    users = User.fromListJson(jsonDecode(response.body));
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return User.fromListJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<User> updateUser(User user) async {
  final response = await http.put(Uri.parse('$apiURL/user/${user.userID}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(user.toJson()));
  if (response.statusCode == 200) {
    // If the server did return a 201 OK,
    // then parse the JSON.
    return User.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update');
  }
}
