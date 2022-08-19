// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// import 'dart:async';
// import 'dart:developer';
// import 'dart:ffi';

// // import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:g4app/pages/notifications.dart';
// import 'package:g4app/pages/search_screen.dart';
// import 'package:g4app/pages/signup.dart';
// import 'package:g4app/services/auth.dart';
// import 'package:g4app/tools/dividerWidget.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_place/src/details/details_result.dart';
// import 'package:location/location.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class MainMapPage extends StatefulWidget {
//   const MainMapPage({Key? key, this.startPosition, this.endPosition})
//       : super(key: key);
//   static const String idScreen = 'main';
//   final DetailsResult? startPosition;
//   final DetailsResult? endPosition;

//   @override
//   State<MainMapPage> createState() => _MainMapPageState();
// }

// class _MainMapPageState extends State<MainMapPage>
//     with TickerProviderStateMixin {
//   final Authservices _auth = Authservices();

//   // creating an object instance called scaffold state so that it can be used for the hamburger for the drawer
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   double bottomPaddingOfMap = 0.0;

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(6.673159, -1.565402),
//     zoom: 14.4746,
//   );

//   late final GoogleMapController _controller;
//   final _locatiion = Location();

//   Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
//   late BitmapDescriptor _markerIcon;
//   List<Polyline> tempPolylines = [];
//   List<Polyline>? polylines = null;
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
//   String googleAPiKey = "AIzaSyAFUP5gFZRz6nfScFF3R5tNpcT2LRyr0i4";

//   void _onMapCreated(GoogleMapController _cntrl)async {
//     _controller = _cntrl;
//      LocationData locData = await _locatiion.getLocation();
//     _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//         target: LatLng(locData.latitude!, locData.longitude!), zoom: 18)));
//   }

//   fetchPolyline() {
//     setState(() {
//       loading = true;
//     });
//     FirebaseFirestore.instance
//         .collection('Potholes')
//         .get()
//         .then((document) async {
//       if (document.docs.isNotEmpty) {
//         for (int i = 0; i < document.docs.length - 1; ++i) {
//           final geoPoint1 = document.docs[i].data()["location"] as GeoPoint;
//           final geoPoint2 = document.docs[i + 1].data()["location"] as GeoPoint;
//           String id = document.docs[i].id;
//           double dist = calcDistance(geoPoint1, geoPoint2);
//           fetchPotholes(document.docs[i]);
//           List<LatLng> latLngsBetweenRange = await _getPolyline(
//               geoPoint1.latitude,
//               geoPoint1.longitude,
//               geoPoint2.latitude,
//               geoPoint2.longitude,
//               id,
//               dist);

//           addpolyline(id, dist, latLngsBetweenRange);
//         }
//         setState(() {
//           polylines = tempPolylines;
//           loading = false;
//         });
//       }
//     });
//   }

//   // add markers function
//   fetchPotholes(pothole) {
//     var markerIdVal = pothole.id;
//     final MarkerId markerId = MarkerId(markerIdVal);
//     final Marker marker = Marker(
//       markerId: markerId,
//       position: LatLng(pothole.data()['location'].latitude,
//           pothole.data()['location'].longitude),
//       infoWindow: InfoWindow(title: "Pothole", snippet: pothole.data()['groupId']),
//       // icon: BitmapDescriptor.defaultMarker,
//       // using created bitmapIcon
//       icon:_markerIcon,
//     );
//     setState(() {
//       _markers[markerId] = marker;
//     });
//   }

//   void _setMarkerIcon() async {
//     // TODO: add a dot image into your assets
//     _markerIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(), 'assets/holes.png');
//   }

//   double calcDistance(geoPoint1, geoPoint2) {
//     double distanceInMeters = Geolocator.distanceBetween(geoPoint1.latitude,geoPoint1.longitude,geoPoint2.latitude,geoPoint2.longitude,);

//     return distanceInMeters;
//   }
//   //todo: this function get the lat longs between the range.
//   Future<List<LatLng>> _getPolyline(double geoPoint1latitude,double geoPoint1longitude,double geoPoint2latitude,double geoPoint2longitude,id,dist)
//   async {
//     List<LatLng> rangeLatLngs = [];
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPiKey,
//       PointLatLng(geoPoint1latitude, geoPoint1longitude),
//       PointLatLng(geoPoint2latitude, geoPoint2longitude),
//       travelMode: TravelMode.driving,
//     );
//     if (result.points.isNotEmpty) {
//       for (PointLatLng point in result.points) {
//         rangeLatLngs.add(LatLng(point.latitude, point.longitude));
//       }
//       return rangeLatLngs;
//     } else {
//       return [];
//     }
//     // await addpolyline(id, dist);
//     // setPolyline();
//   }

//   // this is never used
//   setPolyline() {
//     polylines = tempPolylines;
//     setState(() {});
//   }

//   addpolyline(id, dist, List<LatLng> range) {
//     late Color color;
//     if (dist <= 50) {
//       color = Colors.red;
//     } else if (dist > 50 && dist < 100) {
//       color = Colors.yellow;
//     } else {
//       color = Colors.lightGreen;
//     }

//     tempPolylines.add(
//       Polyline(
//         polylineId: PolylineId(id),
//         color: color,
//         points: range,
//       ),
//     );
//   }
//   @override
//   void initState() {
//     super.initState();
//     _setMarkerIcon();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchPolyline();
//     });
//   }

//   bool loading = true;

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return SafeArea(
//       child: Scaffold(
//         key: scaffoldKey,
//         drawer: Container(
//           color: Colors.white,
//           width: 255.0,

//           ///SIDE NAVIGATION PANEL
//           child: Drawer(
//             child: ListView(
//               children: [
//                 // ignore: sized_box_for_whitespace
//                 Container(
//                   height: 165.0,
//                   child: DrawerHeader(
//                     decoration: const BoxDecoration(
//                       color: Colors.black,
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 32.0,
//                           backgroundImage: AssetImage('assets/user_icon.png'),
//                         ),
//                         SizedBox(
//                           width: 16.0,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(2.0),
//                               child: Container(
//                                 child: Text(
//                                   // '${user.firstName}',
//                                   "adwoa",
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 6.0,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 DividerWidget(),

//                 SizedBox(
//                   height: 12.0,
//                 ),

//                 //Drawer Body
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => Notifications()));
//                   },
//                   child: ListTile(
//                     leading: Icon(Icons.person),
//                     title: Text(
//                       'Visit Profile',
//                       style: TextStyle(fontSize: 15.0),
//                     ),
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(context, '/help');
//                   },
//                   child: ListTile(
//                     leading: Icon(Icons.help_center),
//                     title: Text(
//                       'Help',
//                       style: TextStyle(fontSize: 15.0),
//                     ),
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(context, '/about');
//                   },
//                   child: ListTile(
//                     leading: Icon(Icons.info),
//                     title: Text(
//                       'About',
//                       style: TextStyle(fontSize: 15.0),
//                     ),
//                   ),
//                 ),

//                 ListTile(
//                   onTap: () async {
//                     await _auth.signout();
//                     log('logged out');
//                   },
//                   leading: Icon(Icons.exit_to_app),
//                   title: Text(
//                     'Sign Out',
//                     style: TextStyle(fontSize: 15.0),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             /// Map

//             Builder(builder: (context) {
//               if (loading) return Center(child: CircularProgressIndicator());
//               return GoogleMap(
//                 padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
//                 mapType: MapType.normal,
//                 myLocationButtonEnabled: true,
//                 initialCameraPosition: _kGooglePlex,
//                 myLocationEnabled: true,
//                 zoomGesturesEnabled: true,
//                 zoomControlsEnabled: true,
//                 onMapCreated: _onMapCreated,
//                 markers: Set<Marker>.of(_markers.values),
//                 polylines:Set<Polyline>.of(polylines == null ? [] : polylines!),
//               );
//             }),

//             //Hamburger for drawer
//             /// Hanmburger Menu Icon
//             Positioned(
//               top: 20.0,
//               left: 10.0,
//               child: GestureDetector(
//                 onTap: () {
//                   scaffoldKey.currentState!.openDrawer();
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(22.0),
//                       // ignore: prefer_const_literals_to_create_immutables
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black,
//                           blurRadius: 5.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(0.7, 0.7),
//                         )
//                       ]),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.menu,
//                       color: Colors.black,
//                     ),
//                     radius: 20.0,
//                   ),
//                 ),
//               ),
//             ),

//             // Search icon
//             Positioned(
//               top: 20.0,
//               left: screenWidth * 0.8,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchScreen(),
//                       ));
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(22.0),
//                       // ignore: prefer_const_literals_to_create_immutables
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black,
//                           blurRadius: 5.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(0.1, 0.1),
//                         )
//                       ]),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.search,
//                       color: Colors.black,
//                     ),
//                     radius: 20.0,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
