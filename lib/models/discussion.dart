class Message {
  int msgID;
  int sender;
  String senderName;
  int itemID;
  DateTime date;
  String context;
  List<int> replyIDs;
  int level;

  Message(
    this.msgID,
    this.sender,
    this.senderName,
    this.itemID,
    this.date,
    this.context,
    this.replyIDs,
    this.level,
  );
}
