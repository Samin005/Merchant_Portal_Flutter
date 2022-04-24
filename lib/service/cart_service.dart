import '../models/item.dart';
import '../models/cart_item.dart';

List<CartItem> cart = [];
double totalPrice = 0.0;

void addItemToCart(Item item, int quantity, double unitPrice) {
  if (cart.any((c) => c.item.itemID == item.itemID)) {
    cart.firstWhere((c) => c.item.itemID == item.itemID).quantity += quantity;
  } else {
    cart.add(CartItem(item, quantity, unitPrice));
  }
  updateTotalPrice();
}

void removeItemFromCart(int cartItemIndex) {
  cart.removeAt(cartItemIndex);
  updateTotalPrice();
  if (cart.isEmpty) {
    clearCart();
  }
}

void clearCart() {
  cart.clear();
  updateTotalPrice();
}

void updateTotalPrice() {
  totalPrice = 0.0;
  for (CartItem element in cart) {
    totalPrice += element.item.price * element.quantity;
  }
}

void addQTY(String id) {
  cart[cart.indexWhere((e) => e.item.itemID == id)].quantity += 1;
}

void subtractQTY(String id) {
  if (cart[cart.indexWhere((e) => e.item.itemID == id)].quantity > 1) {
    cart[cart.indexWhere((e) => e.item.itemID == id)].quantity -= 1;
  }
}
