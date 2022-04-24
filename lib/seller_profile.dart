import 'package:flutter/material.dart';

import 'service/seller_service.dart';
import 'seller_home.dart';

class SellerProfile extends StatefulWidget {
  const SellerProfile({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SellerProfileState createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  final _sellerNameController =
      TextEditingController(text: currentSeller?.userName);
  final _sellerEmailController =
      TextEditingController(text: currentSeller?.email);
  final _sellerAddressController =
      TextEditingController(text: currentSeller?.address);
  final _sellerPhoneController =
      TextEditingController(text: currentSeller?.phone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: appDrawerSeller(context),
      body: Container(
          margin: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
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
                        controller: _sellerNameController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        controller: _sellerEmailController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                        controller: _sellerAddressController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone No.',
                        ),
                        controller: _sellerPhoneController,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentSeller?.userName =
                                  _sellerNameController.value.text;
                              currentSeller?.email =
                                  _sellerEmailController.value.text;
                              currentSeller?.address =
                                  _sellerAddressController.value.text;
                              currentSeller?.phone =
                                  _sellerPhoneController.value.text;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Update Successful!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SellerHome(
                                                title:
                                                    'Merchant Portal for Seller',
                                              ),
                                            ),
                                            (route) => false);
                                      },
                                      child: const Text('Back Home'),
                                    )
                                  ],
                                ),
                              );
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
          )),
    );
  }
}
