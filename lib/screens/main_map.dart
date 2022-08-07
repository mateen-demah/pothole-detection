// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g4_user/screens/notifications.dart';
import 'package:g4_user/screens/search_screen.dart';
import 'package:g4_user/screens/signup.dart';
import 'package:g4_user/tools/dividerWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/src/details/details_result.dart';
import 'package:location/location.dart';


class MainMapPage extends StatefulWidget {
  const MainMapPage({Key? key, this.startPosition, this.endPosition}) : super(key: key);
  static const String idScreen = 'main';
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> with TickerProviderStateMixin {

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


  void _onMapCreated(GoogleMapController _cntrl){
    _controller = _cntrl;
    _locatiion.onLocationChanged.listen((l) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(l.latitude!, l.longitude!),
      zoom: 15
      ),),);
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
                    Navigator.pushNamed(context, MaterialPageRoute(builder: (context) => Notifications() ));
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

                GestureDetector(
                  onTap: () {
                    // showConfirmation(); //added functionality for sign out
                  },
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        body: Stack(
          children: [
            /// Map
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: _onMapCreated,
              
            ),

            //Hamburger for drawer
            /// Hanmburger Menu Icon
            Positioned(
              top: 20.0,
              left: 10.0,
              child: GestureDetector(
                onTap: () {
                  scaffoldKey.currentState!.openDrawer();
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
                  Navigator.push( context, MaterialPageRoute( builder: (context) =>
                    SearchScreen(),
                  )
                );
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
                    ]
                  ),
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
