class User {
  String userID;
  String userName;
  String password;
  String email;
  String address;
  String phone;
  List<String> likedItem;
  List<String> dislikedItem;
  bool isSeller;

  User(this.userID, this.userName, this.password, this.email, this.address,
      this.phone, this.likedItem, this.dislikedItem, this.isSeller);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['userID'],
      json['userName'],
      json['password'],
      json['email'],
      json['address'],
      json['phone'],
      json['likedItem'].cast<String>(),
      json['dislikedItem'].cast<String>(),
      json['isSeller'],
    );
  }

  static List<User> fromListJson(List<dynamic> json) {
    List<User> result = <User>[];
    for (Map<String, dynamic> d in json) {
      result.add(User.fromJson(d));
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'userName': userName,
        'password': password,
        'email': email,
        'address': address,
        'phone': phone,
        'likedItem': likedItem,
        'dislikedItem': dislikedItem,
        'isSeller': isSeller,
      };
}
