import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'seller_home.dart';
import 'service/item_service.dart';
import 'user_home.dart';
import 'shopping_cart.dart';

import 'models/user.dart';
import 'models/item.dart';

import 'service/user_service.dart';
import 'service/seller_service.dart';
import 'service/cart_service.dart';
import 'service/shared_service.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({
    Key? key,
    required this.item,
  }) : super(key: key);
  final Item item;

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  final _quantityTextController = TextEditingController(text: '1');
  final _commentTextController = TextEditingController();
  bool _invalid = false;
  bool isVisibleComment = false;
  bool isVisibleReply = false;
  String commentText = "Write a comment...";
  String message = "";
  int replyMsgId = 0;

  @override
  Widget build(BuildContext context) {
    User localUser;
    if (currentUser != null) {
      localUser = currentUser!;
    } else {
      localUser = currentSeller!;
    }
    List<int> commentOrderIndex = [];
    _getOrderedIndex(widget.item.comments, commentOrderIndex);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        leading: CloseButton(
          onPressed: () {
            localUser.isSeller
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellerHome(
                        title: 'Merchant Portal for Seller',
                      ),
                    ),
                  )
                : Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserHome(
                        title: 'G5 Online Shopping',
                      ),
                    ),
                  );
          },
        ),
        actions: [
          Visibility(
            visible: !localUser.isSeller,
            child: shoppingCartButton(context, widget.item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(widget.item.imgURL),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.only(top: 20.0),
                width: double.infinity,
                height: localUser.isSeller ? 150 : 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              widget.item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Muli',
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(widget.item.rating == 0
                                  ? Icons.star_border
                                  : widget.item.rating == 5
                                      ? Icons.star
                                      : Icons.star_half_rounded),
                              Text(
                                '${widget.item.rating}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 5.0,
                        ),
                        child: Text(
                          widget.item.description,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Muli',
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: localUser.isSeller
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                              '\$${widget.item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 30.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Visibility(
                            visible: !localUser.isSeller,
                            child: Row(
                              children: [
                                const Text('Quantity: '),
                                SizedBox(
                                  width: 70,
                                  child: TextField(
                                    controller: _quantityTextController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(8),
                                      errorText: _invalid ? 'Invalid' : null,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !localUser.isSeller,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_quantityTextController.text.isEmpty ||
                                  int.parse(_quantityTextController.text) ==
                                      0) {
                                _invalid = true;
                              } else {
                                _invalid = false;
                                addItemToCart(
                                    widget.item,
                                    int.parse(_quantityTextController.text),
                                    widget.item.price);
                              }
                            });
                          },
                          child: const Text('Add to cart'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                height: 60,
                child: Column(
                  children: [
                    const Divider(color: Colors.black),
                    Row(
                      children: [
                        const SizedBox(width: 8.0),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (!localUser.isSeller) {
                                  if (!currentUser!.likedItem
                                      .contains(widget.item.itemID)) {
                                    currentUser!.likedItem
                                        .add(widget.item.itemID);
                                    widget.item.liked += 1;
                                    if (currentUser!.dislikedItem
                                        .contains(widget.item.itemID)) {
                                      currentUser!.dislikedItem
                                          .remove(widget.item.itemID);
                                      widget.item.disliked -= 1;
                                    }
                                  } else {
                                    currentUser!.likedItem
                                        .remove(widget.item.itemID);
                                    widget.item.liked -= 1;
                                  }
                                  // update item with more/fewer like.
                                  updateItemPUT(Item(
                                          widget.item.itemID,
                                          convertToTitleCase(widget.item.name),
                                          widget.item.description,
                                          widget.item.imgURL,
                                          widget.item.categoryID,
                                          widget.item.price,
                                          widget.item.rating,
                                          widget.item.sellerID,
                                          widget.item.liked,
                                          widget.item.disliked,
                                          widget.item.comments,
                                          widget.item.isVisible))
                                      .then((value) =>
                                          debugPrint('data: ${value.toJson()}'))
                                      .onError((error, stackTrace) =>
                                          debugPrint('error: $error'));
                                  // update user with liked/unliked item
                                  updateUser(currentUser!);
                                }
                              });
                            },
                            child: widget.item.liked > 0
                                ? const Icon(Icons.thumb_up)
                                : const Icon(Icons.thumb_up_outlined),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            "${widget.item.liked}",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (!localUser.isSeller) {
                                  if (!currentUser!.dislikedItem
                                      .contains(widget.item.itemID)) {
                                    currentUser!.dislikedItem
                                        .add(widget.item.itemID);
                                    widget.item.disliked += 1;
                                    if (currentUser!.likedItem
                                        .contains(widget.item.itemID)) {
                                      currentUser!.likedItem
                                          .remove(widget.item.itemID);
                                      widget.item.liked -= 1;
                                    }
                                  } else {
                                    currentUser!.dislikedItem
                                        .remove(widget.item.itemID);
                                    widget.item.disliked -= 1;
                                  }
                                  // update item with more/fewer like.
                                  updateItemPUT(Item(
                                          widget.item.itemID,
                                          convertToTitleCase(widget.item.name),
                                          widget.item.description,
                                          widget.item.imgURL,
                                          widget.item.categoryID,
                                          widget.item.price,
                                          widget.item.rating,
                                          widget.item.sellerID,
                                          widget.item.liked,
                                          widget.item.disliked,
                                          widget.item.comments,
                                          widget.item.isVisible))
                                      .then((value) =>
                                          debugPrint('data: ${value.toJson()}'))
                                      .onError((error, stackTrace) =>
                                          debugPrint('error: $error'));
                                  // update user with liked/unliked item
                                  updateUser(currentUser!);
                                }
                              });
                            },
                            child: widget.item.disliked > 0
                                ? const Icon(Icons.thumb_down)
                                : const Icon(Icons.thumb_down_outlined),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 2.0),
                          child: Text(
                            "${widget.item.disliked}",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                child: const Text(
                                  "Comment",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _handleComment("Write a comment...");
                            }),
                            child: const Icon(Icons.comment_outlined),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.black),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isVisibleComment || isVisibleReply,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentTextController,
                        decoration: InputDecoration(
                          labelText: commentText,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButton(
                      onPressed: () {
                        if (_commentTextController.text.isNotEmpty) {
                          if (isVisibleComment) {
                            setState(() {
                              widget.item.comments.add(
                                Comment(
                                  _getNewMsgId(widget.item.comments),
                                  localUser.userID,
                                  localUser.userName,
                                  DateTime.now(),
                                  _commentTextController.text,
                                  [],
                                  0,
                                ),
                              );
                              isVisibleComment = !isVisibleComment;
                              _commentTextController.text = "";
                            });
                          } else if (isVisibleReply) {
                            setState(() {
                              widget.item.comments.add(
                                Comment(
                                  _getNewMsgId(widget.item.comments),
                                  localUser.userID,
                                  localUser.userName,
                                  DateTime.now(),
                                  _commentTextController.text,
                                  [],
                                  widget
                                          .item
                                          .comments[widget.item.comments
                                              .indexWhere(
                                                  (e) => e.msgID == replyMsgId)]
                                          .level +
                                      1,
                                ),
                              );
                              widget
                                  .item
                                  .comments[widget.item.comments
                                      .indexWhere((e) => e.msgID == replyMsgId)]
                                  .replyIDs
                                  .add(widget.item.comments.last.msgID);
                              isVisibleReply = !isVisibleReply;
                              _commentTextController.text = "";
                            });
                          }
                          setState(() {
                            // update item with new comment.
                            updateItemPUT(Item(
                                    widget.item.itemID,
                                    widget.item.name,
                                    widget.item.description,
                                    widget.item.imgURL,
                                    widget.item.categoryID,
                                    widget.item.price,
                                    widget.item.rating,
                                    widget.item.sellerID,
                                    widget.item.liked,
                                    widget.item.disliked,
                                    widget.item.comments,
                                    widget.item.isVisible))
                                .then((value) =>
                                    debugPrint('data: ${value.toJson()}'))
                                .onError((error, stackTrace) =>
                                    debugPrint('error: $error'));
                          });
                        }
                      },
                      child: const Text("Post"),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                bottom: 20.0,
              ),
              child: SizedBox(
                height: widget.item.comments.length * 85 < 500
                    ? widget.item.comments.length * 85
                    : 300,
                child: ListView.builder(
                  // right item card panel
                  itemCount: widget.item.comments.length,
                  // all items or items of clicked category
                  itemBuilder: (BuildContext context, int index) {
                    return buildCommentCard(
                      context,
                      widget.item.comments[widget.item.comments.indexWhere(
                          (e) => e.msgID == commentOrderIndex[index])],
                      _handleReply,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleComment(t) {
    setState(() {
      commentText = t;
      isVisibleReply = false;
      isVisibleComment = !isVisibleComment;
      replyMsgId = 0;
    });
  }

  void _handleReply(Comment msg, String t) {
    setState(() {
      commentText = "${t}to ${msg.msgID}";
      isVisibleComment = false;
      isVisibleReply = !isVisibleReply;
      replyMsgId = msg.msgID;
    });
  }
}

int _getNewMsgId(List<Comment> comments) {
  int newMsgId = 1;
  if (comments.isNotEmpty) {
    newMsgId = comments.last.msgID + 1;
  }
  return newMsgId;
}

void _addIndex(
    List<Comment> commentsOfItem, List<int> commentOrderIndex, int id) {
  if (commentsOfItem[commentsOfItem.indexWhere((e) => e.msgID == id)]
      .replyIDs
      .isNotEmpty) {
    for (int idi
        in commentsOfItem[commentsOfItem.indexWhere((e) => e.msgID == id)]
            .replyIDs) {
      if (!commentOrderIndex.contains(idi)) {
        commentOrderIndex.add(idi);
        _addIndex(commentsOfItem, commentOrderIndex, idi);
      }
    }
  }
}

void _getOrderedIndex(
    List<Comment> commentsOfItem, List<int> commentOrderIndex) {
  for (Comment i in commentsOfItem) {
    if (!commentOrderIndex.contains(i.msgID)) {
      commentOrderIndex.add(i.msgID);
      if (i.replyIDs.isNotEmpty) {
        for (int ii in i.replyIDs) {
          if (!commentOrderIndex.contains(ii)) {
            commentOrderIndex.add(ii);
            _addIndex(commentsOfItem, commentOrderIndex, ii);
          }
        }
      }
    }
  }
}

Widget buildCommentCard(
  BuildContext context,
  Comment msg,
  _handleReply,
) {
  double indent_1 = msg.level * 30.0;
  double indent_2 = indent_1 + 20.0;
  return Column(
    children: [
      Row(
        children: [
          SizedBox(
            width: indent_1,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.subdirectory_arrow_right),
            ),
          ),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          msg.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          displayDateTime(msg.date),
                        ),
                      ],
                    ),
                    Text(msg.context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      Visibility(
        visible: msg.level <= 5,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _handleReply(msg, "Write a reply..."),
              child: Padding(
                padding: EdgeInsets.only(left: indent_2),
                child: const Text("Reply"),
              ),
            )
          ],
        ),
      )
    ],
  );
}

Widget shoppingCartButton(BuildContext context, Item _item) {
  return FloatingActionButton(
    elevation: 0.0,
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingCart(
            title: 'Shopping Cart',
            itemID: _item.itemID,
          ),
        ),
      );
    },
    tooltip: 'Add to cart',
    child: Badge(
      badgeContent: Text(
        '${cart.length}',
        style: const TextStyle(color: Colors.white),
      ),
      child: const Icon(Icons.shopping_cart_outlined),
      showBadge: cart.isNotEmpty ? true : false,
    ),
  );
}
