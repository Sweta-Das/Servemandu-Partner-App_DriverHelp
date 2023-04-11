// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servemandu_partner/assistantMethods/get_current_location.dart';
import 'package:servemandu_partner/global/global.dart';
import 'package:servemandu_partner/maps/map_utils.dart';
import 'package:servemandu_partner/splashScreen/splash_screen.dart';


class ServiceDeliveringScreen extends StatefulWidget
{
  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? sellerId;
  String? getOrderId;

  ServiceDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
  });


  @override
  _ServiceDeliveringScreenState createState() => _ServiceDeliveringScreenState();
}


class _ServiceDeliveringScreenState extends State<ServiceDeliveringScreen>
{

  String orderTotalAmount = "";

  confirmParcelHasBeenDelivered(getOrderID, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) + (double.parse(perParcelDeliveryAmount))).toString();

    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID)
        .update(
          {
          "status": "ended",
          "address": completeAddress,
          "lat": position!.latitude,  // updated position of the rider
          "lng": position!.longitude,
          "earnings": perParcelDeliveryAmount, // pay per service delivery
          }
        ).then((value) 
          {
            FirebaseFirestore.instance
              .collection("riders")
              .doc(sharedPreferences!.getString("uid"))
              .update(
                {
                  "earnings": riderNewTotalEarningAmount,// total earnings of (rider) service provider
                });
          }).then((value) 
            {
             FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerId)
              .update(
                {
                  "earnings": (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString(), //total earnings of seller
                });             
            }).then((value) 
              {
                FirebaseFirestore.instance
                .collection("users")
                .doc(purchaserId)
                .collection("orders")
                .doc(getOrderID)
                .update(
                  {
                    "status": "ended",
                    "riderUID": sharedPreferences!.getString("uid"),
                  });
              });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  getOrderTotalAmount()
  {
    FirebaseFirestore.instance
    .collection("orders") // from orders collection of firestore
    .doc(widget.getOrderId)
    .get()
    .then((snap) 
    {
      orderTotalAmount = snap.data()!["totalAmount"].toString(); // getting total amount from firestore
      widget.sellerId = snap.data()!["sellerUID"].toString(); // getting real seller from firestore
    }).then((value) 
        {
          getSellerData();
        });
  }

  getSellerData()
  {
    FirebaseFirestore.instance
    .collection("sellers")
    .doc(widget.sellerId)
    .get()
    .then((snap)
      {
        previousEarnings = snap.data()!["earnings"].toString();
      });
  }

  @override
  void initState() {
    super.initState();

    //service provider location updates (rider)
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm2.png",
            // width: 350,
          ),
          const SizedBox(height: 5,),

          GestureDetector(
            onTap:()
            {
              //show location from rider current location towards user home location
              MapUtils.lauchMapFromSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat,widget.purchaserLng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   'images/resturant.png',
                //   width: 50,
                // ),
                const SizedBox(width: 7,),

                Column(
                  children: const [
                    SizedBox(height: 12,),
                    Text(
                      "Show Service Drop-off Location",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40,),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  //service provider location updates (rider)
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin:  FractionalOffset(0.0, 0.0),
                        end:  FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      )
                  ),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Service has been Delivered - Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
