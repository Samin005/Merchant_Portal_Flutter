class Item {
  String itemID;
  String name;
  String description;
  String imgURL;
  String categoryID;
  double price;
  double rating;
  String sellerID;
  int liked;
  int disliked;
  List<Comment> comments;
  bool isVisible;

  Item(
    this.itemID,
    this.name,
    this.description,
    this.imgURL,
    this.categoryID,
    this.price,
    this.rating,
    this.sellerID,
    this.liked,
    this.disliked,
    this.comments,
    this.isVisible,
  );

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      json['itemID'],
      json['name'],
      json['description'],
      json['imgURL'],
      json['categoryID'],
      json['price'].toDouble(),
      json['rating'].toDouble(),
      json['sellerID'],
      json['liked'],
      json['disliked'],
      Comment.fromListJson(json['comments']),
      json['isVisible'],
    );
  }

  Map<String, dynamic> toJson() => {
        'itemID': itemID,
        'name': name,
        'description': description,
        'imgURL': imgURL,
        'categoryID': categoryID,
        'price': price,
        'rating': rating,
        'sellerID': sellerID,
        'liked': liked,
        'disliked': disliked,
        'comments': Comment.toListJson(comments),
        'isVisible': isVisible,
      };

  static List<Item> fromListJson(List<dynamic> json) {
    List<Item> result = <Item>[];
    for (Map<String, dynamic> d in json) {
      result.add(Item.fromJson(d));
    }
    return result;
  }
}

class Comment {
  int msgID;
  String sender;
  String senderName;
  DateTime date;
  String context;
  List<int> replyIDs;
  int level;

  Comment(
    this.msgID,
    this.sender,
    this.senderName,
    this.date,
    this.context,
    this.replyIDs,
    this.level,
  );

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        json['msgID'],
        json['sender'],
        json['senderName'],
        DateTime.parse(json['date']),
        json['context'],
        json['replyIDs'].cast<int>(),
        json['level']);
  }

  static List<Comment> fromListJson(List<dynamic> json) {
    List<Comment> result = <Comment>[];
    for (Map<String, dynamic> d in json) {
      result.add(Comment.fromJson(d));
    }
    return result;
  }

  static List<dynamic> toListJson(List<Comment> comments) {
    List<dynamic> result = <dynamic>[];
    for (Comment c in comments) {
      result.add(c.toJson());
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'msgID': msgID,
        'sender': sender,
        'senderName': senderName,
        'date': date.toIso8601String(),
        'context': context,
        'replyIDs': replyIDs,
        'level': level
      };
}

class Category {
  String categoryID;
  String categoryName;
  String imageURL;
  bool isVisible;

  Category(
    this.categoryID,
    this.categoryName,
    this.imageURL,
    this.isVisible,
  );
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(json['categoryID'], json['categoryName'], json['imageURL'],
        json['isVisible']);
  }

  static List<Category> fromListJson(List<dynamic> json) {
    List<Category> result = <Category>[];
    for (Map<String, dynamic> d in json) {
      result.add(Category.fromJson(d));
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'categoryID': categoryID,
        'categoryName': categoryName,
        'imageURL': imageURL,
        'isVisible': isVisible
      };
}
