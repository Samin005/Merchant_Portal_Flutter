import 'dart:io';

import 'package:flutter/foundation.dart' as fd;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models/item.dart';
import 'models/order.dart';

import 'service/shared_service.dart';
import 'service/user_service.dart';
import 'service/pdf_mobile.dart' if (dart.library.html) 'service/pdf_web.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({
    Key? key,
    required this.title,
    required this.ordersHisOfUserByItemNum,
    required this.orderDate,
    required this.totalOrderPrice,
    required this.items,
    required this.categories,
  }) : super(key: key);

  final String title;
  final List<OrderHistory> ordersHisOfUserByItemNum;
  final DateTime orderDate;
  final double totalOrderPrice;
  final List<Item> items;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    List<List<String>> data = [];
    for (int i = 0; i < ordersHisOfUserByItemNum.length; i++) {
      data.add([
        items
            .firstWhere((e) => e.itemID == ordersHisOfUserByItemNum[i].itemID)
            .name,
        categories
            .firstWhere((e) =>
                e.categoryID ==
                items
                    .firstWhere(
                        (e) => e.itemID == ordersHisOfUserByItemNum[i].itemID)
                    .categoryID)
            .categoryName,
        '${ordersHisOfUserByItemNum[i].qty}',
        '\$ ${items.firstWhere((e) => e.itemID == ordersHisOfUserByItemNum[i].itemID).price.toStringAsFixed(2)}',
        '\$ ${(items.firstWhere((e) => e.itemID == ordersHisOfUserByItemNum[i].itemID).price * ordersHisOfUserByItemNum[i].qty).toStringAsFixed(2)}'
      ]);
    }

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
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: Text(
              'INVOICE',
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
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
                    textAlign: TextAlign.center,
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                      tooltip: 'Download PDF',
                      onPressed: () async {
                        final pdf = pw.Document();

                        pdf.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat.a4,
                            build: (pw.Context context) {
                              return pw.Column(
                                children: [
                                  pw.Center(
                                    child: pw.Text(
                                      'INVOICE',
                                      style: pw.TextStyle(
                                        fontSize: 60.0,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          'Order Number: ${ordersHisOfUserByItemNum.first.uniqueOrderNum}',
                                          style: pw.TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          'Customer: ${users.where((e) => e.userID == ordersHisOfUserByItemNum.first.userID).first.userName}',
                                          style: pw.TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          'Order Date: ${displayDate(orderDate)}',
                                          style: const pw.TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          textAlign: pw.TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // ),
                                  pw.Table.fromTextArray(
                                    headers: [
                                      'Item',
                                      'Category',
                                      'Quanity',
                                      'Unit Price',
                                      'Total',
                                    ],
                                    data: data,
                                    border: null,
                                    headerStyle: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold),
                                    headerDecoration: const pw.BoxDecoration(
                                        color: PdfColors.grey300),
                                    cellHeight: 30,
                                    cellAlignments: {
                                      0: pw.Alignment.centerLeft,
                                      1: pw.Alignment.centerLeft,
                                      2: pw.Alignment.centerRight,
                                      3: pw.Alignment.centerRight,
                                      4: pw.Alignment.centerRight,
                                    },
                                  ),
                                  pw.Divider(color: PdfColors.grey400),
                                  pw.Row(
                                    children: [
                                      pw.Spacer(flex: 6),
                                      pw.Expanded(
                                        flex: 4,
                                        child: pw.Column(
                                          children: [
                                            pw.Row(children: [
                                              pw.Expanded(
                                                child: pw.Text(
                                                  'Total amount due',
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              pw.Text(
                                                '\$${totalOrderPrice.toStringAsFixed(2)}',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 14),
                                                textAlign: pw.TextAlign.right,
                                              ),
                                            ]),
                                            pw.SizedBox(
                                                height: 2 * PdfPageFormat.mm),
                                            pw.Container(
                                                height: 1,
                                                color: PdfColors.grey400),
                                            pw.SizedBox(
                                                height: 0.5 * PdfPageFormat.mm),
                                            pw.Container(
                                                height: 1,
                                                color: PdfColors.grey400),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 2 * PdfPageFormat.mm),
                                  pw.Divider(color: PdfColors.grey400),
                                  pw.Row(
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          'Shipping Details: ${ordersHisOfUserByItemNum.first.shippingDetails.replaceAll(';', '\n')}',
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        );

                        String fileName =
                            "invoice-${ordersHisOfUserByItemNum.first.orderID}-${users.where((e) => e.userID == ordersHisOfUserByItemNum.first.userID).first.userName}-${displayDate(orderDate)}.pdf";

                        if (fd.kIsWeb || Platform.isAndroid) {
                          final bytes = await pdf.save();
                          saveAndLaunchFile(bytes, fileName);
                        } else {
                          final file = File(fileName);
                          await file.writeAsBytes(await pdf.save());
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Invoice is saved as PDF: invoice-${ordersHisOfUserByItemNum.first.uniqueOrderNum}-${users.where((e) => e.userID == ordersHisOfUserByItemNum.first.userID).first.userName}-${displayDate(orderDate)}.pdf',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        size: 30,
                      )),
                ),
              ],
            ),
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
              columns: const [
                DataColumn(
                  label: Text("Item"),
                ),
                DataColumn(
                  label: Text(
                    "Category",
                  ),
                ),
                DataColumn(
                  label: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Qty.",
                    ),
                  ),
                ),
                DataColumn(
                  label: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Unit Price",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataColumn(
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
                          Text(items
                              .firstWhere((e) => e.itemID == itemInfo.itemID)
                              .name),
                        ),
                        DataCell(
                          Text(categories
                              .firstWhere((e) =>
                                  e.categoryID ==
                                  items
                                      .firstWhere(
                                          (e) => e.itemID == itemInfo.itemID)
                                      .categoryID)
                              .categoryName),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                                width: 20, child: Text('${itemInfo.qty}')),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '\$' +
                                  items
                                      .firstWhere(
                                          (e) => e.itemID == itemInfo.itemID)
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
                                  (items
                                              .firstWhere((e) =>
                                                  e.itemID == itemInfo.itemID)
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
