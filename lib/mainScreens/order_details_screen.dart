// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, non_constant_identifier_names, avoid_types_as_parameter_names, avoid_unnecessary_containers, prefer_interpolation_to_compose_strings, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servemandu_partner/models/address.dart';
import 'package:servemandu_partner/widgets/progress_bar.dart';
import 'package:servemandu_partner/widgets/shipment_address_design.dart';
import 'package:servemandu_partner/widgets/status_banner.dart';


class OrderDetailsScreen extends StatefulWidget
{
  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}




class _OrderDetailsScreenState extends State<OrderDetailsScreen>
{
  String orderStatus = "";
  String orderByUser = "";
  String sellerID = "";


  getOrderInfo()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get().then((DocumentSnapshot)
    {
      orderStatus = DocumentSnapshot.data()!["status"].toString();
      orderByUser = DocumentSnapshot.data()!["orderBy"].toString();
      sellerID = DocumentSnapshot.data()!["sellerUID"].toString();

    });
  }

  @override
  void initState() {
    super.initState();

    getOrderInfo();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID)
              .get(),
              
          builder: (c, snapshot)
          {
            Map? dataMap;
            if(snapshot.hasData)
            {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
                    child: Column(
                      children: [
                        StatusBanner(
                          status: dataMap!["isSuccess"],
                          orderStatus: orderStatus,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Rs.  " + dataMap["totalAmount"].toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Order Id = " + widget.orderID!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Order at: " +
                                DateFormat("dd MMMM, yyyy - hh:mm aa")
                                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        const Divider(thickness: 4,),
                        orderStatus == "ended"
                            ? Image.asset("images/success.jpg")
                            : Image.asset("images/confirm_pick.png"),
                        const Divider(thickness: 4,),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("users")
                              .doc(orderByUser)
                              .collection("userAddress")
                              .doc(dataMap["addressID"])
                              .get(),
                              
                          builder: (c, snapshot)
                          {
                            return snapshot.hasData
                                ? ShipmentAddressDesign(
                                    model: Address.fromJson(
                                      snapshot.data!.data()! as Map<String, dynamic>
                                    ),
                                    orderStatus: orderStatus,
                                    orderId: widget.orderID,
                                    sellerId: sellerID,
                                    orderByUser: orderByUser,
                                  )
                                : Center(child: circularProgress(),);
                          },
                        ),
                      ],
                    ),
                  )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}
