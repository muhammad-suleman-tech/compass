import 'dart:async';

import 'package:compassapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


// import 'package:second_proj/main.dart';
// import 'package:second_proj/pages/HomePage.dart';
// import 'package:workout/pages/weightTracker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  InAppPurchase _iap = InAppPurchase.instance;
  bool available = true;
  late StreamSubscription subscription;
  final String myProductId = "geocompass"; //sub-monthly-020
  bool purchase = false;
  List purchaseList = [];
  List product = [];

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2)).then((value) {
      final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
      purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {}, onError: (error) {});
      setData();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MyApp()));
    });

    super.initState();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("Purchase pending");
      } else {
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error!);
          if (purchaseDetails.error!.message ==
                  "BillingResponse.itemAlreadyOwned" ||
              purchaseDetails.error!.message ==
                  "BillingResponse.developerError") {
            _iap.restorePurchases();
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            tryPayment = false;
          });
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => MyApp()));
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool tryPayment = true;
  bool showPayButton = false;
  setData() async {
    available = await _iap.isAvailable();
    if (available) {
      await _iap.restorePurchases().then((value) => {});
      Future.delayed(const Duration(seconds: 2)).then((value) {
        if (tryPayment) {
          setState(() {
            showPayButton = true;
          });
          getProduct();
        }
      });
    }
  }

  Future<void> getProduct() async {
    Set<String> ids = Set.from(["geocompass"]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    print('Could not find ----> ${response.notFoundIDs.length}/${ids.length}');
    print(response.notFoundIDs);
    setState(() {
      print("HUmayun");
      product = response.productDetails;
      print(product);
    });
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: product[0]);
    // bool data = await _iap.buyConsumable(purchaseParam: purchaseParam);
    await _iap.buyConsumable(purchaseParam: purchaseParam).then((value) {});
    // await _iap
    //     .buyNonConsumable(purchaseParam: purchaseParam)
    //     .then((value) => {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                  child: const Image(image: AssetImage('assets/logo.png'))),
            ),
            if (showPayButton)
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color(0xff7c1034)),
                  onPressed: () {
                    setData();
                  },
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 20),
                  ))
          ],
        ),
      ),
    );
  }
}
