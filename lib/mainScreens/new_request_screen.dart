// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servemandu_partner/assistantMethods/assistant_methods.dart';
import 'package:servemandu_partner/widgets/order_card.dart';
import 'package:servemandu_partner/widgets/progress_bar.dart';
import 'package:servemandu_partner/widgets/simple_app_bar.dart';



class NewRequestScreen extends StatefulWidget
{
  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}



class _NewRequestScreenState extends State<NewRequestScreen>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(title: "New Booking",),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "normal")
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (c, snapshot)
          {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (c, index)
                    {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("items")
                            .where("itemID", whereIn: seperateOrderServiceIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["serviceIDs"]))
                            .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                            .orderBy("publishedDate", descending: true)
                            .get(),
                        builder: (c, snap)
                        {
                          return snap.hasData
                              ? OrderCard(
                            itemCount: snap.data!.docs.length,
                            data: snap.data!.docs,
                            orderID: snapshot.data!.docs[index].id,
                            //seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                          )
                              : Center(child: circularProgress());
                        },
                      );
                    },
                  )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}
