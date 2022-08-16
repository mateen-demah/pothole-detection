// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g4app/pages/notifications.dart';
import 'package:g4app/pages/search_screen.dart';
import 'package:g4app/pages/signup.dart';
import 'package:g4app/services/auth.dart';
import 'package:g4app/tools/dividerWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/src/details/details_result.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class MainMapPage extends StatefulWidget {
  const MainMapPage({Key? key, this.startPosition, this.endPosition})
      : super(key: key);
  static const String idScreen = 'main';
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage>
    with TickerProviderStateMixin {
  final Authservices _auth = Authservices();

  // creating an object instance called scaffold state so that it can be used for the hamburger for the drawer
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double bottomPaddingOfMap = 0.0;

  static final CameraPosition _kGooglePlex = CameraPosition(
    // target: LatLng(37.42796133580664, -122.085749655962),
    target: LatLng(6.673159, -1.565402),
    zoom: 14.4746,
  );

  late final GoogleMapController _controller;
  final _locatiion = Location();

  List<Polyline> polylines = [];
  List<LatLng> polylineCoordinates = [];
  // PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyAFUP5gFZRz6nfScFF3R5tNpcT2LRyr0i4";

  void _onMapCreated(GoogleMapController _cntrl) {
    _controller = _cntrl;
    _locatiion.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
        ),
      );
    });
  }

  fetchPolyline() {
    FirebaseFirestore.instance.collection('Potholes').get().then((document) {
      if (document.docs.isNotEmpty) {
        for (int i = 0; i < document.docs.length - 1; ++i) {
          calcDistance(document.docs[i].data(), document.docs[i + 1].data());
        }
        setState(() {});
      }
    });
  }

  calcDistance(Map<String, dynamic> data1, Map<String, dynamic> data2) {
    // log((data1['location'] as GeoPoint).);
    final geoPoint1 = data1["location"] as GeoPoint;
    final geoPoint2 = data2["location"] as GeoPoint;

    double distanceInMeters = Geolocator.distanceBetween(
      geoPoint1.latitude,
      geoPoint1.longitude,
      geoPoint2.latitude,
      geoPoint2.longitude,
    );

    _getPolyline(geoPoint1, geoPoint2, data1['groupId'], distanceInMeters);
  }

  // _addPolyLine() {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //       polylineId: id, color: Colors.red, points: polylineCoordinates);
  //   polylines[id] = polyline;
  //   setState(() {});
  // }

  _getPolyline(geoPoint1, geoPooint2, id, dist) {
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //     googleAPiKey,
    //     PointLatLng(origin.latitude, origin.longitude),
    //     PointLatLng(destination.latitude, destination.longitude),
    //     travelMode: TravelMode.driving,
    //     wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //   });
    // }

    // polylinesCoordinates.add(LatLng(origin))

    late Color color;
    if (dist < 50) {
      color = Colors.red;
    } else if (100 > dist && dist < 200) {
      color = Colors.yellow;
    } else {
      color = Colors.green;
    }

    polylines.add(
      Polyline(
        polylineId: PolylineId(id),
        color: color,
        width: 3,
        points: [
          LatLng(geoPoint1.latitude, geoPoint1.longitude),
          LatLng(geoPooint2.latitude, geoPooint2.longitude)
        ],
      ),
    );

    log(polylines.toString());

    // _addPolyLine();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("docu");
      fetchPolyline();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: Container(
          color: Colors.white,
          width: 255.0,

          ///SIDE NAVIGATION PANEL
          child: Drawer(
            child: ListView(
              children: [
                // ignore: sized_box_for_whitespace
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32.0,
                          backgroundImage: AssetImage('assets/user_icon.png'),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                child: Text(
                                  // '${user.firstName}',
                                  "adwoa",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                DividerWidget(),

                SizedBox(
                  height: 12.0,
                ),

                //Drawer Body
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                  },
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Visit Profile',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                  child: ListTile(
                    leading: Icon(Icons.help_center),
                    title: Text(
                      'Help',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      'About',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),

                ListTile(
                  onTap: () async {
                    await _auth.signout();
                    log('logged out');
                  },
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15.0),
                  ),
                )
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            /// Map
            Builder(builder: (context) {
              log(Set<Polyline>.of(polylines).toString());
              return GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: false,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: _onMapCreated,
                polylines: Set<Polyline>.of(polylines),
              );
            }),

            //Hamburger for drawer
            /// Hanmburger Menu Icon
            Positioned(
              top: 20.0,
              left: 10.0,
              child: GestureDetector(
                onTap: () {
                  // scaffoldKey.currentState!.openDrawer();
                  fetchPolyline(); //TODO: revert to normal function.
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.0),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                    radius: 20.0,
                  ),
                ),
              ),
            ),

            // Search icon
            Positioned(
              top: 20.0,
              left: screenWidth * 0.8,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.0),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 177, 199, 238),
                          blurRadius: 6.0,
                          spreadRadius: 0.9,
                          offset: Offset(0.1, 0.1),
                        )
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                      // color: Colors.black,
                    ),
                    radius: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
