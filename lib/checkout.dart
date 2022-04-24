import 'dart:math';

import 'package:flutter/material.dart';

import 'user_home.dart';

import 'models/cart_item.dart';
import 'models/order.dart';

import 'service/cart_service.dart';
import 'service/user_service.dart';
import 'service/order_service.dart';

class Checkout extends StatelessWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      drawer: appDrawer(context),
      body: Container(
        margin: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Total Cost: \$ ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Shipping Details: ${currentUser?.userName}; Address: ${currentUser?.address}; Phone: ${currentUser?.phone}',
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String newOrderID = "";
                int newOrderNum = 1;
                if (orderHistories.isNotEmpty) {
                  newOrderNum = orderHistories
                          .map((e) => e.orderNum)
                          .toSet()
                          .toList()
                          .reduce(max) +
                      1;
                }
                String newUniqueOrderNum =
                    '${currentUser!.userID}-$newOrderNum';
                for (CartItem cItem in cart) {
                  postNewOrder(
                    OrderHistory(
                      newOrderID,
                      newUniqueOrderNum,
                      newOrderNum,
                      currentUser!.userID,
                      cItem.item.sellerID,
                      cItem.item.itemID,
                      cItem.quantity,
                      '${currentUser?.userName}; Address: ${currentUser?.address}; Phone: ${currentUser?.phone}',
                      DateTime.now(),
                      "new",
                    ),
                  );
                }
                cart.clear();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Order Successful!'),
                    content: Text("Order Number: $newUniqueOrderNum"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          totalPrice = 0;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserHome(
                                  title: 'G5 Online Shopping',
                                ),
                              ),
                              (route) => false);
                        },
                        child: const Text('Back Home'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('Confirm Order'),
            )
          ],
        ),
      ),
    );
  }
}
