import 'package:flutter/material.dart';

import 'service/user_service.dart';
import 'user_home.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _userNameController =
      TextEditingController(text: currentUser?.userName);
  final _userEmailController = TextEditingController(text: currentUser?.email);
  final _userAddressController =
      TextEditingController(text: currentUser?.address);
  final _userPhoneController = TextEditingController(text: currentUser?.phone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        )),
        drawer: appDrawer(context),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 500,
              margin: const EdgeInsets.all(15.0),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      width: 130,
                      child: Icon(Icons.person_outline_rounded, size: 80),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'User Name',
                      ),
                      controller: _userNameController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      controller: _userEmailController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                      controller: _userAddressController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Phone No.',
                      ),
                      controller: _userPhoneController,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentUser?.userName =
                                _userNameController.value.text;
                            currentUser?.email =
                                _userEmailController.value.text;
                            currentUser?.address =
                                _userAddressController.value.text;
                            currentUser?.phone =
                                _userPhoneController.value.text;
                            updateUser(currentUser!)
                                .then((value) => {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title:
                                              const Text('Update Successful!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const UserHome(
                                                        title:
                                                            'G5 Online Shopping',
                                                      ),
                                                    ),
                                                    (route) => false);
                                              },
                                              child: const Text('Back Home'),
                                            )
                                          ],
                                        ),
                                      )
                                    })
                                .onError((error, stackTrace) => {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text(
                                              'Something went wrong, please try again later'),
                                          content: Text(error.toString()),
                                        ),
                                      )
                                    });
                          });
                        },
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
