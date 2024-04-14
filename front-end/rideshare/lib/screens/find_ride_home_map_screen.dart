import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place_picker/google_place_picker.dart';

class FindRideHomeMapScreen extends StatefulWidget {
  const FindRideHomeMapScreen({super.key});

  @override
  State<FindRideHomeMapScreen> createState() => _FindRideHomeMapScreenState();
}

class _FindRideHomeMapScreenState extends State<FindRideHomeMapScreen> {

  late GoogleMapController _controller;
  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom:14.0);

  Set<Marker> markers = {};

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
            zoomControlsEnabled: false,
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _determineLocation();
            }
            ),

        ],
      )
    );
  }

  Future<void> _determineLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      // Request permission
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('Location permission denied');
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error('Location permissions are permanently denied');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(position.latitude,position.longitude), zoom: 14.0)
        )
    );
    markers.clear();
    markers.add(
      Marker(markerId: MarkerId('currentLocation'),
      position: LatLng(position.latitude,position.longitude))
    );
    setState(() {});
  }
}