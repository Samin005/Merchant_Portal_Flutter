import 'cart_item.dart';

// Shopping History Orders
class OrderHistory {
  String orderID, uniqueOrderNum, userID, sellerID;
  int orderNum, qty;
  String itemID, shippingDetails, status;
  DateTime dateTime;

  OrderHistory(
      this.orderID, // object id
      this.uniqueOrderNum, // unique order id
      this.orderNum, // nth order of the user
      this.userID,
      this.sellerID,
      this.itemID,
      this.qty,
      this.shippingDetails,
      this.dateTime, // date and time of the order
      this.status); // "new", "completed"

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
        json['orderID'],
        json['uniqueOrderNum'],
        json['orderNum'],
        json['userID'],
        json['sellerID'],
        json['itemID'],
        json['qty'],
        json['shippingDetails'],
        DateTime.parse(json['dateTime']),
        json['status']);
  }

  static List<OrderHistory> fromListJson(List<dynamic> json) {
    List<OrderHistory> result = <OrderHistory>[];
    for (Map<String, dynamic> d in json) {
      result.add(OrderHistory.fromJson(d));
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'orderID': orderID,
        'uniqueOrderNum': uniqueOrderNum,
        'orderNum': orderNum,
        'userID': userID,
        'sellerID': sellerID,
        'itemID': itemID,
        'qty': qty,
        'shippingDetails': shippingDetails,
        'dateTime': dateTime.toIso8601String(),
        'status': status,
      };
}

// Shopping Cart Order
class Order {
  int orderID;
  String userID;
  String sellerID;
  String date;
  OrderDetail orderDetails;

  Order(this.orderID, this.userID, this.sellerID, this.date, this.orderDetails);
}

class OrderDetail {
  List<CartItem> items;
  double price;
  String shippingInfo;

  OrderDetail(this.items, this.price, this.shippingInfo);
}
