import 'dart:convert';

import '../models/item.dart';
import '../service/shared_service.dart';
import 'package:http/http.dart' as http;

List<Category> categories = [];

Future<List<Category>> getAllCategories() async {
  final response = await http.get(Uri.parse('$apiURL/category'));
  if (response.statusCode == 200) {
    categories = Category.fromListJson(jsonDecode(response.body));
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Category.fromListJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<Category> postNewCategory(Category category) async {
  final response = await http.post(Uri.parse('$apiURL/category'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(category.toJson()));
  if (response.statusCode == 201) {
    // If the server did return a 201 Created,
    // then parse the JSON.
    return Category.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to post');
  }
}

Future<Category> updateCategoryPUT(Category category) async {
  final response =
      await http.put(Uri.parse('$apiURL/category/${category.categoryID}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(category.toJson()));
  if (response.statusCode == 200) {
    // If the server did return a 201 OK,
    // then parse the JSON.
    return Category.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update');
  }
}

Future<String> categoryDELETE(Category category) async {
  final response =
      await http.delete(Uri.parse('$apiURL/category/${category.categoryID}'));
  if (response.statusCode == 200) {
    // If the server did return a 201 OK,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to delete');
  }
}
