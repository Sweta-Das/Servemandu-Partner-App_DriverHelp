
// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servemandu_partner/assistantMethods/get_current_location.dart';
import 'package:servemandu_partner/authentication/auth_screen.dart';
import 'package:servemandu_partner/mainScreens/earnings_screen.dart';
import 'package:servemandu_partner/mainScreens/history_screen.dart';
import 'package:servemandu_partner/mainScreens/new_request_screen.dart';
import 'package:servemandu_partner/mainScreens/not-yet-delivered-screen.dart';
import 'package:servemandu_partner/mainScreens/service_in_progress_screen.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  Card makeDashboardItem(String title,IconData iconData, int index ){
    return Card(
     elevation: 2,
     margin: const EdgeInsets.all(8) ,
     child: Container(
      decoration: index ==0 || index==3 || index ==4
       ?const BoxDecoration(
       gradient: LinearGradient(
        colors: [
          Colors.amber,
          Colors.cyan,
         ],
         begin:  FractionalOffset(0.0, 0.0),
         end:  FractionalOffset(1.0, 0.0),
         stops: [0.0, 1.0],
         tileMode: TileMode.clamp,
       )
      ):
        const BoxDecoration(
          gradient: LinearGradient(
          colors: [
          Colors.redAccent,
          Colors.amber,
            ],
          begin:  FractionalOffset(0.0, 0.0),
          end:  FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
           ) ,
        ),
       child: InkWell(
         onTap: ()
         {
           if(index==0)
             {
               //New request for the service
               Navigator.push(context, MaterialPageRoute(builder: (c)=> NewRequestScreen()));
             }
           if(index==1)
           {
             // Service in progress
             Navigator.push(context, MaterialPageRoute(builder: (c)=> ServiceInProgressScreen()));

           }
           if(index==2)
           {
             // Not yet accepted service
             Navigator.push(context, MaterialPageRoute(builder: (c)=> NotYetDeliveredScreen()));

           }
           if(index==3)
           {
             // History
             Navigator.push(context, MaterialPageRoute(builder: (c)=> HistoryScreen()));


           }
           if(index==4)
           {
             // Total Earnings
             Navigator.push(context, MaterialPageRoute(builder: (c)=> const EarningsScreen()));
           }

           if(index==5)
           {
             // Logout
             firebaseAuth.signOut().then((value) {
               Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
             });
           }
         },
         child:Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           mainAxisSize: MainAxisSize.min,
           verticalDirection: VerticalDirection.down,
           children: [
             const SizedBox( height: 50.0),
             Center(
               child: Icon(
                 iconData,
                 size: 40,
                 color: Colors.black,
               ),
             ),
           const SizedBox( height: 10.0),
           Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
             )
            ),
          ],
         ) ,
       ),
      ),
    );}

  restrictBlockedUsersFromUsingApp() async
  {
    await FirebaseFirestore.instance.collection("riders")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot)
    {
      if(snapshot.data()!["status"]!="approved")
      {
        firebaseAuth.signOut();
        Fluttertoast.showToast(msg: "You have been blocked.");
        
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MySplashScreen()));
      }

      else
      {
        UserLocation uLocation = UserLocation();
        uLocation.getCurrentLocation();
        getPerParcelDeliveryAmount(); // get Service Delivery amount
        getRiderPreviousEarnings();
      }
    }
    );
  }
  
  @override
  void initState() {
    super.initState();

    restrictBlockedUsersFromUsingApp();
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();
    getPerParcelDeliveryAmount(); // get Service Delivery amount
    getRiderPreviousEarnings();
  }


 //get service providers (riders) previous earnings
  getRiderPreviousEarnings()
  {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get().then((snap)
          {
            previousRiderEarnings = snap.data()!["earnings"].toString();
          });
  }

  //getPerService Delivery Amount for the service provider(rider) 
  getPerParcelDeliveryAmount(){
    FirebaseFirestore.instance.collection("perDelivery")
        .doc("O2hywV8rhqOYzvOGpfGY")
        .get()
        .then((snap) 
        {
          perParcelDeliveryAmount = snap.data()!["amount"].toString();
        });
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
        ),

        title: Text(
          // ignore: prefer_interpolation_to_compose_strings
          "Welcome " +
          sharedPreferences!.getString("name")! + "!",
          // resources.getIdentifier(name, "drawable", activity?.packageName),
          style: const TextStyle(
            fontSize: 25.0,
            color: Colors.black,
            fontFamily: "Signatra",
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 1),
        child: GridView.count(crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
          children: [
            makeDashboardItem("New Request Service", Icons.assignment, 0),
            makeDashboardItem("Service in Progress", Icons.airport_shuttle,1),
            makeDashboardItem(" Not yet Accepted Service", Icons.location_history, 2),
            makeDashboardItem("History", Icons.done, 3),
            makeDashboardItem("Total Earnings", Icons.monetization_on, 4),
            makeDashboardItem("Logout", Icons.logout, 5),
          ],
        ),
      ),

    );
  }
}
