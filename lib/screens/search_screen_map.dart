import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:g4_user/screens/main_map.dart';
import 'package:g4_user/tools/constant.dart';
import 'package:g4_user/tools/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/src/details/details_result.dart';

class SearchMapScreen extends StatefulWidget {
  const SearchMapScreen({Key? key, this.endPosition, this.startPosition}) : super(key: key);
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  late CameraPosition _initialPosition;
  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();


  @override
  void initState(){
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(
        widget.startPosition!.geometry!.location!.lat!,
        widget.startPosition!.geometry!.location!.lng!
      ),
      zoom: 14.4746,
    );
  }



  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id, 
      color: Colors.red, 
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS,
      PointLatLng(
          widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!
        ),
      PointLatLng(
          widget.endPosition!.geometry!.location!.lat!,
          widget.endPosition!.geometry!.location!.lng!
        ),
      travelMode: TravelMode.driving
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }



  @override
  Widget build(BuildContext context) {

    Set<Marker> _markers = {
      Marker(
        markerId: MarkerId('start'),
        position: LatLng(
          widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!
        ),
        // icon: pinSymbol('red')
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: MarkerId('end'),
        position: LatLng(
          widget.endPosition!.geometry!.location!.lat!,
          widget.endPosition!.geometry!.location!.lng!
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainMapPage()));
          }, 
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            // ignore: unnecessary_const
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          )
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 0.0),
            mapType: MapType.normal,
            // myLocationButtonEnabled: true,
            initialCameraPosition: _initialPosition,
            // myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            markers: Set.from(_markers),
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              Future.delayed(
                Duration(milliseconds: 2000),
                () {controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    MapUtils.boundsFromLatLngList(
                      _markers.map((loc) => loc.position).toList()
                    ),1
                  ),
                );

                _getPolyline();




                }
              );
            },
          ),
        ],
      )
    );
  }
}
