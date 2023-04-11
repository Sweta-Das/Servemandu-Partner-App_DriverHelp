// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servemandu_partner/assistantMethods/assistant_methods.dart';
import 'package:servemandu_partner/global/global.dart';
import 'package:servemandu_partner/widgets/order_card.dart';
import 'package:servemandu_partner/widgets/progress_bar.dart';
import 'package:servemandu_partner/widgets/simple_app_bar.dart';



// ignore: use_key_in_widget_constructors
class NotYetDeliveredScreen extends StatefulWidget
{
  @override
  _NotYetDeliveredScreenState createState() => _NotYetDeliveredScreenState();
}



class _NotYetDeliveredScreenState extends State<NotYetDeliveredScreen>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(title: "To be Deliver",),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("riderUID", isEqualTo: sharedPreferences!.getString("uid"))
              .where("status", isEqualTo: "delivering")
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
