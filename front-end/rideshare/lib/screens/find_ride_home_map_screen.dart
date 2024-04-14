import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindRideHomeMapScreen extends StatefulWidget {
  const FindRideHomeMapScreen({super.key});

  @override
  State<FindRideHomeMapScreen> createState() => _FindRideHomeMapScreenState();
}

class InputForm extends StatefulWidget{
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputForm();
}

class _FindRideHomeMapScreenState extends State<FindRideHomeMapScreen> {

  late GoogleMapController _controller;
  static const CameraPosition initialPosition = CameraPosition(
      target: LatLng(33.684566, -117.826508), zoom: 14.0);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Find Ride"),
          elevation: 6,
          shadowColor: Colors.grey,
          centerTitle: true,
          backgroundColor: Colors.lightBlue[200],
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
            InputForm()
          ],
        )
    );
  }

  Future<void> _determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.0)
        )
    );
    markers.clear();
    markers.add(
        Marker(markerId: MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude))
    );
    setState(() {});
  }
}

class _InputForm extends State<InputForm>{
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _seatsController = TextEditingController(text: '1');
  final _startsearchFieldController = TextEditingController();
  final _endsearchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 2,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            color: Colors.lightBlue[50],
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Column(
              children: [
                TextField(
                  controller: _startsearchFieldController,
                  autofocus: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    hintText: 'Start Location',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      borderSide: BorderSide.none, // Make the border invisible
                    ),
                    prefixIcon: Icon(
                        Icons.radio_button_checked,
                        color: Colors.deepPurple[100]
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _endsearchFieldController,
                  autofocus: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    hintText: 'Destination Location',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      borderSide: BorderSide.none, // Make the border invisible
                    ),
                    prefixIcon: Icon(
                      Icons.radio_button_checked,
                      color: Colors.deepOrange[100],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          labelText: 'Start time',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            borderSide: BorderSide.none, // Make the border invisible
                          ),
                          prefixIcon: Icon(
                            Icons.schedule,
                            color: Colors.deepPurple[100],
                          ),
                        ),
                        readOnly: true, // Make the field read-only
                        onTap: () {
                          // Open a date and time picker when the field is tapped
                          _selectTime(context, _startTimeController);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          labelText: 'End time',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            borderSide: BorderSide.none, // Make the border invisible
                          ),
                          prefixIcon: Icon(
                          Icons.schedule,
                          color: Colors.deepOrange[100],
                        ),
                        ),
                        readOnly: true, // Make the field read-only
                        onTap: () {
                          // Open a date and time picker when the field is tapped
                          _selectTime(context, _endTimeController);
                        },
                      )
                    )
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }
}
