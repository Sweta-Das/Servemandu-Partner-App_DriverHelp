// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, library_private_types_in_public_api, non_constant_identifier_names, avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:servemandu_partner/assistantMethods/get_current_location.dart';
import 'package:servemandu_partner/mainScreens/service_delivering_screen.dart';
import 'package:servemandu_partner/maps/map_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servemandu_partner/global/global.dart';

class ServiceProvidingScreen extends StatefulWidget
{
  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;

  ServiceProvidingScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
  });

  @override
  _ServiceProvidingScreenState createState() => _ServiceProvidingScreenState();
}



class _ServiceProvidingScreenState extends State<ServiceProvidingScreen>
{
  double? sellerLat, sellerLng;

  getSellerData() async
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .get()
        .then((DocumentSnapshot)
    {
      sellerLat = DocumentSnapshot.data()!["lat"];
      sellerLng = DocumentSnapshot.data()!["lng"];
    });
  }

  @override
  void initState() {
    super.initState();

    getSellerData();
  }

  confirmParcelHasBeenPicked(getOrderID, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID)
        .update(
          {
          "status": "delivering",
          "address": completeAddress,
          "lat": position!.latitude,  // updated position of the rider
          "lng": position!.longitude,
          }
        );

    Navigator.push(context, MaterialPageRoute(builder: (c)=> ServiceDeliveringScreen(
      purchaserId: purchaserId, //customer details
      purchaserAddress: purchaserAddress,
      purchaserLat: purchaserLat,
      purchaserLng: purchaserLng,
      sellerId: sellerId,
      getOrderId: getOrderID,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
              "images/confirm1.png",
             width: 350,
              ),
          
          const SizedBox(height: 5,),

          GestureDetector(
            onTap:()
            {
              //show location from rider current location towards seller location
              MapUtils.lauchMapFromSourceToDestination(position!.latitude, position!.longitude, sellerLat, sellerLng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   'images/resturant.png',
                //   width: 25,
                // ),

                const SizedBox(width: 10,),

                Column(
                  children: const [
                     SizedBox(height: 12,),
                     Text(
                      "Show Main Office Location",
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
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenPicked(
                      widget.getOrderID,
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
                      "Service Confirming to be Delivered!",
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
