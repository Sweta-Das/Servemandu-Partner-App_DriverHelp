import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Position? position;
List<Placemark>? placeMarks;
String completeAddress="";

String perParcelDeliveryAmount=""; // per service delivery amount
String previousEarnings=""; // it is main company old earnings
String previousRiderEarnings="";//it is rider old earnings