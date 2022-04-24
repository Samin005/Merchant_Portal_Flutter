import 'package:flutter/material.dart';

import 'user_home.dart';
import 'invoice.dart';

import 'models/order.dart';
import 'models/item.dart';

import 'service/shared_service.dart';
import 'service/user_service.dart';
import 'service/order_service.dart';

class ShoppingHistory extends StatefulWidget {
  const ShoppingHistory({
    Key? key,
    required this.title,
    required this.items,
    required this.categories,
  }) : super(key: key);

  final String title;
  final List<Item> items;
  final List<Category> categories;

  @override
  _ShoppingHistoryState createState() => _ShoppingHistoryState();
}

class _ShoppingHistoryState extends State<ShoppingHistory> {
  late Future<List<OrderHistory>> futureUserOrders;
  final ScrollController _historyController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureUserOrders = getUserOrders(currentUser!.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        drawer: appDrawer(context),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const CircularProgressIndicator();
            }
            if (userOrderHistories.isEmpty) {
              // show "No shopping history"
              return const Center(
                  child: Text(
                'No shopping history',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ));
            } else {
              // get order history of all user or current user
              List<OrderHistory> ordersHisOfUser = userOrderHistories;

              // group order history by order number and add to a list
              Set<String> orderNumOfUser = {};
              for (var e in ordersHisOfUser) {
                orderNumOfUser.add(e.uniqueOrderNum);
              }
              List<List<OrderHistory>> ordersHisOfUserList = [];
              for (String n in orderNumOfUser) {
                List<OrderHistory> tempOrderHistory =
                    orderHistories.where((e) => e.uniqueOrderNum == n).toList();
                ordersHisOfUserList.add(tempOrderHistory);
              }
              ordersHisOfUserList
                  .sort((a, b) => b.first.dateTime.compareTo(a.first.dateTime));
              return ListView.separated(
                controller: _historyController,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.lightBlue,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: ordersHisOfUserList.length,
                itemBuilder: (context, index) {
                  List<OrderHistory> ordersHisOfUserByItemNum =
                      ordersHisOfUserList[index];
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
                                          .firstWhere(
                                              (e) => e.itemID == a.itemID)
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
                                          .firstWhere((e) =>
                                              e.itemID == itemInfo.itemID)
                                          .name),
                                    ),
                                    DataCell(
                                      Text(widget.categories
                                          .firstWhere((e) =>
                                              e.categoryID ==
                                              widget.items
                                                  .firstWhere((e) =>
                                                      e.itemID ==
                                                      itemInfo.itemID)
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
                                                      e.itemID ==
                                                      itemInfo.itemID)
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Total: \$${totalOrderPrice.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
          future: futureUserOrders,
        ));
  }
}
