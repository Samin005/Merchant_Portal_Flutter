import 'dart:convert';

import '../models/item.dart';
import '../service/shared_service.dart';
import 'package:http/http.dart' as http;

List<Item> items = [];

Future<List<Item>> getAllItems() async {
  final response = await http.get(Uri.parse('$apiURL/item'));
  if (response.statusCode == 200) {
    items = Item.fromListJson(jsonDecode(response.body));
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Item.fromListJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<Item> postNewItem(Item item) async {
  final response = await http.post(Uri.parse('$apiURL/item'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(item.toJson()));
  if (response.statusCode == 201) {
    // If the server did return a 201 Created,
    // then parse the JSON.
    return Item.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to post');
  }
}

Future<String> postManyNewItems(List<Item> items) async {
  final response = await http.post(Uri.parse('$apiURL/item/postmany'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(items));
  if (response.statusCode == 200) {
    // If the server did return a 200,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to post');
  }
}

Future<Item> updateItemPUT(Item item) async {
  final response = await http.put(Uri.parse('$apiURL/item/${item.itemID}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(item.toJson()));
  if (response.statusCode == 200) {
    // If the server did return a 201 OK,
    // then parse the JSON.
    return Item.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update');
  }
}

Future<String> itemDELETE(String itemID) async {
  final response = await http.delete(Uri.parse('$apiURL/item/$itemID'));
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

Future<String> updateUncategorizedItems(List<Item> itemsToUncategorize) async {
  final response = await http.put(Uri.parse('$apiURL/item/uncategorized'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(itemsToUncategorize));
  if (response.statusCode == 200) {
    // If the server did return a 201 OK,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to uncategorize items');
  }
}
