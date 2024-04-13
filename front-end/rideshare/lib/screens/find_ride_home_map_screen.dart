import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindRideHomeMapScreen extends StatefulWidget {
  const FindRideHomeMapScreen({super.key});

  @override
  State<FindRideHomeMapScreen> createState() => _FindRideHomeMapScreenState();
}

class _FindRideHomeMapScreenState extends State<FindRideHomeMapScreen> {

  final Completer<GoogleMapController> _controller = Completer();
  
  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom:14.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Ride"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Stack(
        children: [
            GoogleMap(
            initialCameraPosition: initialPosition,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            }
            ),

        ],
      )
    );
  }
}
