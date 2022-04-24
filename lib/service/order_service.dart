import 'dart:convert';

import '../models/order.dart';
import '../service/shared_service.dart';
import 'package:http/http.dart' as http;

List<OrderHistory> orderHistories = [];
List<OrderHistory> userOrderHistories = [];

Future<List<OrderHistory>> getAllOrders() async {
  final response = await http.get(Uri.parse('$apiURL/order'));
  if (response.statusCode == 200) {
    orderHistories = OrderHistory.fromListJson(jsonDecode(response.body));
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return OrderHistory.fromListJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<List<OrderHistory>> getUserOrders(String userID) async {
  final response = await http.get(Uri.parse('$apiURL/order/user/$userID'));
  if (response.statusCode == 200) {
    userOrderHistories = OrderHistory.fromListJson(jsonDecode(response.body));
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return OrderHistory.fromListJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<OrderHistory> postNewOrder(OrderHistory orderHistory) async {
  final response = await http.post(Uri.parse('$apiURL/order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(orderHistory.toJson()));
  if (response.statusCode == 201) {
    // If the server did return a 201 Created,
    // then parse the JSON.
    return OrderHistory.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to post');
  }
}
