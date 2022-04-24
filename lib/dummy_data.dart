// import 'models/item.dart';
// import 'models/order.dart';
// import 'models/user.dart';

// List<User> sellers = [];
// List<User> users = [];

// List<Category> categories = [];
// List<Item> items = [];
// List<Comment> comments = [];

// List<OrderHistory> orderHistories = [];

// String convertToTitleCase(String text) {
//   if (text.isEmpty) {
//     return "";
//   }

//   if (text.length <= 1) {
//     return text.toUpperCase();
//   }

//   // Split string into multiple words
//   final List<String> words = text.split(' ');

//   // Capitalize first letter of each words
//   final capitalizedWords = words.map((word) {
//     if (word.trim().isNotEmpty) {
//       final String firstLetter = word.trim().substring(0, 1).toUpperCase();
//       final String remainingLetters = word.trim().substring(1);

//       return '$firstLetter$remainingLetters';
//     }
//     return '';
//   });

//   // Join/Merge all words back to one String
//   return capitalizedWords.join(' ').replaceAll('"', '');
// }

// void createDummyData() {
//   // creating 2 dummy sellers
//   users.add(User(1, 'seller1', 'seller123', '', '', '', [], [], true));
//   users.add(User(2, 'seller2', 'seller234', '', '', '', [], [], true));

//   // creating 3 dummy customers
//   users.add(User(3, 'user1', 'user123', 'user1@gmail.com', 'Road 1, Ottawa',
//       '123456789', [], [], false));
//   users.add(User(4, 'user2', 'user234', 'user2@gmail.com', 'Road 2, Ottawa',
//       '234567890', [], [], false));
//   users.add(User(5, 'user3', 'user345', 'user3@gmail.com', 'Road 3, Ottawa',
//       '345678901', [], [], false));

//   // creating 3 dummy categories
//   categories
//       .add(Category(0, 'Uncategorized', 'images/g5-design-logo.png', false));
//   categories
//       .add(Category(1, 'Groceries', 'images/image_banner_grocery.png', true));
//   categories.add(Category(2, 'Electronics', 'images/Image Banner 2.png', true));
//   categories.add(Category(3, 'Clothing', 'images/Image Banner 3.png', true));

//   // creating 7 dummy items
//   items.add(Item(
//     1,
//     "Banana",
//     "Six to seven large bananas",
//     'images/Three-Banana-PNG.png',
//     1,
//     1.99,
//     4.5,
//     1,
//     0,
//     0,
//     [
//       Comment(
//         1,
//         users[2].userID,
//         users[2].userName,
//         DateTime(2021, 12, 25, 13, 20),
//         "comment 1",
//         [2],
//         0,
//       ),
//       Comment(
//         2,
//         users[0].userID,
//         users[0].userName,
//         DateTime(2021, 12, 25, 14, 11),
//         "reply 1 of comment 1",
//         [3],
//         1,
//       ),
//       Comment(
//         3,
//         users[2].userID,
//         users[2].userName,
//         DateTime(2021, 12, 25, 14, 19),
//         "reply 1 of reply 1 of comment 1",
//         [],
//         2,
//       ),
//       Comment(
//         4,
//         users[4].userID,
//         users[4].userName,
//         DateTime(2021, 12, 25, 13, 44),
//         "comment 2",
//         [],
//         0,
//       ),
//     ],
//   ));
//   items.add(Item(2, "Apple", "1 kg fresh apples", "images/apples.png", 1, 6.99,
//       4.1, 1, 0, 0, []));
//   items.add(Item(3, "Google Pixel 6", "6 GB RAM and 128 GB Storage",
//       "images/pixel.png", 2, 900.00, 4.7, 2, 0, 0, []));
//   items.add(Item(4, "Macbook Pro", "16 inch Macbook Pro with M1 chip",
//       "images/macbook-pro-16-inch.png", 2, 1699.00, 4.4, 2, 0, 0, [
//     Comment(1, users[3].userID, users[3].userName, DateTime(2021, 10, 8, 0, 29),
//         "Do you have the red cover?", [], 0)
//   ]));
//   items.add(Item(5, "Leather Jacket", "Vintage unisex black leather jacket",
//       "images/leather_jacket_PNG1.png", 3, 60.99, 4.1, 1, 0, 0, []));
//   items.add(Item(
//       6,
//       "PS5",
//       "Play Station 5 Digital Edition",
//       "images/playstation-5-with-dualsense-front-product-shot-01-ps5-en-30jul20.png",
//       2,
//       699.99,
//       4.4,
//       1,
//       0,
//       0, []));
//   items.add(Item(7, "Watermelon", "One mini watermelon",
//       "images/Watermelon-Transparent-Image.png", 1, 4.99, 4.8, 2, 0, 0, []));
//   items.add(Item(8, "Onion", "A bag of 10 onions",
//       "images/Onion-Free-Download-PNG.png", 1, 3.99, 4.23, 2, 0, 0, []));
//   items.add(Item(9, "Carrot", "A batch of carrots", "images/carrots.png", 1,
//       2.99, 4.62, 1, 0, 0, []));
//   items.add(Item(
//       10,
//       "Tie",
//       "Kissties striped tie (red)",
//       "images/kissties-mens-striped-tie-red-color.png",
//       3,
//       15.99,
//       4.6,
//       1,
//       0,
//       0, []));
//   items.add(Item(
//       11,
//       "Shoes",
//       "Men shoes (brown)",
//       "images/Pair-Of-Polished-Leather-Men-Shoes-png-hd.png",
//       3,
//       109.98,
//       4.2,
//       2,
//       0,
//       0, []));
//   items.add(Item(12, "Sunglasses", "Women sunglasses",
//       "images/Sunglasses-PNG-Pic.png", 3, 1799.98, 4.9, 2, 0, 0, []));
//   items.add(Item(13, "Hat", "Cowboy hat (brown)",
//       "images/cowboy-hat-png-13.png", 3, 269.48, 4.4, 2, 0, 0, []));
//   items.add(Item(14, "Razor", "Blue electric shaver",
//       "images/Vifycim-Electric-Razor.png", 2, 149.99, 4.0, 1, 0, 0, []));
//   items.add(Item(15, "Coffee Machine", "Professional automatic coffee machine",
//       "images/Coffee-Machine-PNG-Picture.png", 2, 3395.99, 4.7, 1, 0, 0, []));

//   // creating 5 dummy order histories
//   orderHistories.add(
//     OrderHistory(
//       1,
//       users[4].userID,
//       items[0].sellerID,
//       "Banana",
//       "Groceries",
//       3,
//       1.99,
//       'shipping info 1',
//       DateTime(2022, 1, 5),
//       "complete",
//     ),
//   );
//   orderHistories.add(
//     OrderHistory(
//       1,
//       users[4].userID,
//       items[1].sellerID,
//       "Apple",
//       "Groceries",
//       5,
//       6.99,
//       orderHistories[0].shippingDetails,
//       orderHistories[0].dateTime,
//       orderHistories[0].status,
//     ),
//   );
//   orderHistories.add(
//     OrderHistory(
//       1,
//       users[4].userID,
//       items[2].sellerID,
//       "Google Pixel 6",
//       "Electronics",
//       7,
//       900,
//       orderHistories[0].shippingDetails,
//       orderHistories[0].dateTime,
//       orderHistories[0].status,
//     ),
//   );
//   orderHistories.add(
//     OrderHistory(
//       2,
//       users[3].userID,
//       items[4].sellerID,
//       "Leather Jacket",
//       "Clothing",
//       1,
//       60.99,
//       'shipping info 2',
//       DateTime(2022, 2, 3),
//       "complete",
//     ),
//   );
//   orderHistories.add(
//     OrderHistory(
//       2,
//       users[3].userID,
//       items[3].sellerID,
//       "Macbook Pro",
//       "Electronics",
//       2,
//       1699,
//       orderHistories[3].shippingDetails,
//       orderHistories[3].dateTime,
//       orderHistories[3].status,
//     ),
//   );
// }
