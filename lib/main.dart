import 'package:flutter/material.dart';

// file to hold temporary data for current user or seller
import 'models/item.dart';
// import 'models/order.dart';
import 'service/category_service.dart';
import 'service/item_service.dart';
// import 'service/order_service.dart';
import 'service/user_service.dart';
import 'service/seller_service.dart';

import 'models/user.dart';
import 'user_home.dart';
import 'seller_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Merchant Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInForm(title: 'G5 Design Sign In'),
        '/userhome': (context) => const UserHome(
              title: 'G5 Online Shopping',
            ),
        '/sellerhome': (context) => const SellerHome(
              title: 'Merchant Portal for Seller',
            ),
      },
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SignInFormState createState() => _SignInFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _SignInFormState extends State<SignInForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _signInUserIdController = TextEditingController(text: 'user1');
  bool _invalidUsername = false;
  final _signInPasswordController = TextEditingController(text: 'user123');
  bool _invalidPassword = false;
  bool passenable = true; //boolean value to track password view enable disable.
  late Future<List<User>> futureUsers;
  late Future<List<Category>> futureCategories;
  late Future<List<Item>> futureItems;
  // late Future<List<OrderHistory>> futureOrderHistories;

  @override
  void initState() {
    super.initState();
    futureUsers = getAllUsers();
    futureCategories = getAllCategories();
    futureItems = getAllItems();
    // futureOrderHistories = getAllOrders();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _signInUserIdController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          }
          return FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              }
              return FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const CircularProgressIndicator();
                  }
                  // return FutureBuilder(
                  //   builder: (context, snapshot) {
                  //     if (snapshot.hasData == false) {
                  //       return const CircularProgressIndicator();
                  //     }
                  return Container(
                    margin: const EdgeInsets.all(32.0),
                    child: ListView(
                      // provide scrolling function
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            child: Image.asset('images/g5-design-logo.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: FittedBox(
                              // allow to resize if the window is too small
                              child: Column(
                                children: [
                                  Text(
                                    'Sign in',
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  const Text(
                                    'Welcome!',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Sign in with your username and password",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _signInUserIdController,
                            onTap: () {
                              setState(() {
                                _invalidUsername = false;
                              });
                            },
                            decoration: InputDecoration(
                              icon: const Icon(Icons.person),
                              labelText: 'Username*',
                              errorText: _invalidUsername
                                  ? 'Username cannot be empty'
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Color(0xFF757575)),
                                gapPadding: 10,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Color(0xFF757575)),
                                gapPadding: 10,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                gapPadding: 10,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(color: Colors.red),
                                gapPadding: 10,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _signInPasswordController,
                            onTap: () {
                              setState(() {
                                _invalidPassword = false;
                              });
                            },
                            obscureText: passenable,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.lock),
                              labelText: 'Password*',
                              errorText: _invalidPassword
                                  ? 'Password cannot be empty.'
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Color(0xFF757575)),
                                gapPadding: 10,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Color(0xFF757575)),
                                gapPadding: 10,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                gapPadding: 10,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(color: Colors.red),
                                gapPadding: 10,
                              ),
                              contentPadding: const EdgeInsets.all(12.0),
                              suffix: IconButton(
                                icon: passenable
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    passenable = !passenable;
                                  });
                                },
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  //   },
                  //   future: futureOrderHistories,
                  // );
                },
                future: futureItems,
              );
            },
            future: futureCategories,
          );
        },
        future: futureUsers,
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          setState(() {
            if (_signInUserIdController.value.text.isNotEmpty &&
                _signInPasswordController.value.text.isNotEmpty) {
              _invalidUsername = false;
              _invalidPassword = false;
              // check if user/seller name exist and
              // the corresponding password is correct
              Iterable<User> iterableSeller = users.where((element) =>
                  element.isSeller &&
                  element.userName == _signInUserIdController.value.text &&
                  element.password == _signInPasswordController.value.text);
              Iterable<User> iterableUser = users.where((element) =>
                  element.isSeller == false &&
                  element.userName == _signInUserIdController.value.text &&
                  element.password == _signInPasswordController.value.text);
              if (iterableSeller.isNotEmpty) {
                updateCurrentSeller(iterableSeller.first);
              } else if (iterableUser.isNotEmpty) {
                updateCurrentUser(iterableUser.first);
              }
              if (currentSeller != null) {
                // if seller, navigate to seller homepage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SellerHome(title: 'Merchant Portal for Seller'),
                  ),
                );
              } else if (currentUser != null) {
                // if user, navigate to user homepage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserHome(
                      title: 'G5 Online Shopping',
                    ),
                  ),
                );
                // }
              } else {
                // else, login fail: invalid username/password
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                    title: Text('Login Failed!'),
                    content: Text("Invalid username/password"),
                  ),
                );
              }
            } else {
              if (_signInUserIdController.value.text.isEmpty) {
                _invalidUsername = true;
              }
              if (_signInPasswordController.value.text.isEmpty) {
                _invalidPassword = true;
              }
            }
          });
        },
        tooltip: 'Press here to sign in',
        child: const Icon(Icons.login_sharp),
      ),
    );
  }
}
