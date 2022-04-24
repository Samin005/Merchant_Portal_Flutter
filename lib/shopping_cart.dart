import 'package:flutter/material.dart';

import 'user_home.dart';
import 'item_details.dart';
import 'checkout.dart';

import 'models/item.dart';

import 'service/cart_service.dart';
import 'service/item_service.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({
    Key? key,
    required this.title,
    required this.itemID,
  }) : super(key: key);
  final String title;
  final String itemID;

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        leading: CloseButton(onPressed: () {
          widget.itemID == ''
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserHome(
                      title: 'G5 Online Shopping',
                    ),
                  ),
                )
              : {
                  Navigator.pop(context),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetails(
                        item:
                            items.firstWhere((e) => e.itemID == widget.itemID),
                      ),
                    ),
                  )
                };
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(cart.length, (index) {
            Item item = cart[index].item;
            return Row(
              children: [
                SizedBox(
                  width: 88.0,
                  child: AspectRatio(
                    aspectRatio: 0.88,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(item.imgURL),
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                    ),
                    Text.rich(
                      TextSpan(
                        text: "\$${item.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF7643),
                        ),
                        children: [
                          TextSpan(
                            text: "    x${cart[index].quantity}",
                            style: const TextStyle(color: Colors.black12),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: (() {
                        setState(() {
                          addQTY(item.itemID);
                          updateTotalPrice();
                        });
                      }),
                      icon: const Icon(Icons.arrow_drop_up_sharp),
                    ),
                    IconButton(
                      onPressed: (() {
                        setState(() {
                          subtractQTY(item.itemID);
                          updateTotalPrice();
                        });
                      }),
                      icon: const Icon(Icons.arrow_drop_down_sharp),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: (() {
                    setState(() {
                      removeItemFromCart(index);
                      updateTotalPrice();
                    });
                  }),
                  icon: const Icon(Icons.delete_forever_outlined),
                ),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Container(
        height: 174,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -15),
              blurRadius: 20,
              color: const Color(0xFFDADADA).withOpacity(0.15),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
              width: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text.rich(
                    TextSpan(
                      text: "Total:\n",
                      children: [
                        TextSpan(
                          text: "\$${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (cart.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => const AlertDialog(
                            title: Text('Your cart is empty!'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Checkout(),
                          ),
                        );
                      }
                    },
                    child: const Text('Proceed to checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
