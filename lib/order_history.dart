import 'package:flutter/material.dart';

import 'seller_home.dart';
import 'invoice.dart';

import 'models/order.dart';
import 'models/item.dart';

import 'service/shared_service.dart';
import 'service/user_service.dart';
import 'service/order_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({
    Key? key,
    required this.title,
    required this.items,
    required this.categories,
  }) : super(key: key);

  final String title;
  final List<Item> items;
  final List<Category> categories;

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String dropdownValue = 'All';
  List<OrderHistory> ordersHisOfUser = [];
  late Future<List<OrderHistory>> futureOrderHistories;
  final ScrollController _historyController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureOrderHistories = getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    // get all user names for dropdown list
    List<String> orderHistoryUserID =
        orderHistories.map((e) => e.userID).toSet().toList();
    List<String> orderHistoryUserNames = ['All'];
    for (String id in orderHistoryUserID) {
      orderHistoryUserNames
          .add(users.firstWhere((e) => e.userID == id).userName);
    }
    orderHistoryUserNames.sort();

    // get order history of all user or specific user
    if (dropdownValue == 'All') {
      ordersHisOfUser = orderHistories;
    } else {
      ordersHisOfUser = orderHistories
          .where((e) =>
              e.userID ==
              users.firstWhere((u) => u.userName == dropdownValue).userID)
          .toList();
    }

    // group order history by order number and add to a list
    Set<String> allOrderNum = {};
    for (var e in ordersHisOfUser) {
      // allOrderNum.add(e.orderNum);
      allOrderNum.add(e.uniqueOrderNum);
    }
    List<List<OrderHistory>> ordersHistoryByOrderNum = [];
    for (String n in allOrderNum) {
      List<OrderHistory> tempOrderHistory =
          ordersHisOfUser.where((e) => e.uniqueOrderNum == n).toList();
      ordersHistoryByOrderNum.add(tempOrderHistory);
    }
    ordersHistoryByOrderNum
        .sort((a, b) => b.first.dateTime.compareTo(a.first.dateTime));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(widget.title)),
            const Expanded(
              child: Text(
                'Order History of User:',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: DropdownButton<String>(
                focusNode: FocusNode(canRequestFocus: false),
                dropdownColor: Colors.deepOrange,
                focusColor: Colors.green,
                value: dropdownValue,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ),
                elevation: 0,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: orderHistoryUserNames
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      drawer: appDrawerSeller(context),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          }
          if (ordersHistoryByOrderNum.isEmpty) {
            // show "No order history"
            return const Center(
                child: Text(
              'No order history',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ));
          } else {
            return ListView.separated(
              controller: _historyController,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.lightBlue,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: ordersHistoryByOrderNum.length,
              itemBuilder: (context, index) {
                List<OrderHistory> ordersHisOfUserByItemNum =
                    ordersHistoryByOrderNum[index];
                ordersHisOfUserByItemNum.sort(
                  (a, b) => widget.items
                      .firstWhere((e) => e.itemID == a.itemID)
                      .name
                      .toLowerCase()
                      .compareTo(widget.items
                          .firstWhere((e) => e.itemID == b.itemID)
                          .name
                          .toLowerCase()),
                );
                DateTime orderDate = DateTime.now();
                double totalOrderPrice = 0.0;
                for (OrderHistory item in ordersHisOfUserByItemNum) {
                  totalOrderPrice = totalOrderPrice +
                      (item.qty *
                          widget.items
                              .firstWhere((e) => e.itemID == item.itemID)
                              .price);
                }
                if (orderDate != ordersHisOfUserByItemNum.first.dateTime) {
                  orderDate = ordersHisOfUserByItemNum.first.dateTime;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Order Number: ${ordersHisOfUserByItemNum.first.uniqueOrderNum}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Customer: ${users.where((e) => e.userID == ordersHisOfUserByItemNum.first.userID).first.userName}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Order Date: ${displayDate(orderDate)}',
                            style: const TextStyle(
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvoicePage(
                                  title: "Invoice",
                                  ordersHisOfUserByItemNum:
                                      ordersHisOfUserByItemNum,
                                  orderDate: orderDate,
                                  totalOrderPrice: totalOrderPrice,
                                  items: widget.items,
                                  categories: widget.categories,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.print),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        showBottomBorder: true,
                        headingTextStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.greenAccent),
                        sortColumnIndex: 1,
                        sortAscending: true,
                        columns: [
                          DataColumn(
                            label: const Text("Item"),
                            onSort: (_, __) {
                              setState(
                                () {
                                  ordersHisOfUserByItemNum.sort(
                                    (a, b) => widget.items
                                        .firstWhere((e) => e.itemID == a.itemID)
                                        .name
                                        .toLowerCase()
                                        .compareTo(widget.items
                                            .firstWhere(
                                                (e) => e.itemID == b.itemID)
                                            .name
                                            .toLowerCase()),
                                  );
                                },
                              );
                            },
                          ),
                          const DataColumn(
                            label: Text(
                              "Category",
                            ),
                          ),
                          const DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Qty.",
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Unit Price",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text(
                              "Total",
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        rows: ordersHisOfUserByItemNum
                            .map(
                              (itemInfo) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(widget.items
                                        .firstWhere(
                                            (e) => e.itemID == itemInfo.itemID)
                                        .name),
                                  ),
                                  DataCell(
                                    Text(widget.categories
                                        .firstWhere((e) =>
                                            e.categoryID ==
                                            widget.items
                                                .firstWhere((e) =>
                                                    e.itemID == itemInfo.itemID)
                                                .categoryID)
                                        .categoryName),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                          width: 20,
                                          child: Text('${itemInfo.qty}')),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '\$' +
                                            widget.items
                                                .firstWhere((e) =>
                                                    e.itemID == itemInfo.itemID)
                                                .price
                                                .toStringAsFixed(2),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '\$' +
                                            (widget.items
                                                        .firstWhere((e) =>
                                                            e.itemID ==
                                                            itemInfo.itemID)
                                                        .price *
                                                    itemInfo.qty)
                                                .toStringAsFixed(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Shipping Details: ${ordersHisOfUserByItemNum.first.shippingDetails}',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Total: \$${totalOrderPrice.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        future: futureOrderHistories,
      ),
    );
  }
}
