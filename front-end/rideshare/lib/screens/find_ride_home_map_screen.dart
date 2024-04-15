import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class FindRideHomeMapScreen extends StatefulWidget {
  const FindRideHomeMapScreen({super.key});

  @override
  State<FindRideHomeMapScreen> createState() => _FindRideHomeMapScreenState();
}

class _FindRideHomeMapScreenState extends State<FindRideHomeMapScreen> {

  late GoogleMapController _controller;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _startsearchFieldController = TextEditingController();
  final _endsearchFieldController = TextEditingController();
  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the text field controller when the widget is disposed
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startsearchFieldController.dispose();
    _endsearchFieldController.dispose();
    _controller.dispose();
    super.dispose();
  }
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
          backgroundColor: Colors.lightBlue[100],
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
            Positioned(
                top: 2,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: _startsearchFieldController,
                          autofocus: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                            labelText: 'Start Location',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                              borderSide: BorderSide.none, // Make the border invisible
                            ),
                            prefixIcon: Icon(
                                Icons.radio_button_checked,
                                color: Colors.deepPurple[100]
                            ),
                          ),
                          onTap: () => _openAutoComplete(context, _startsearchFieldController),
                          onChanged: (value) => _openAutoComplete(context, _startsearchFieldController),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _endsearchFieldController,
                          autofocus: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                            labelText: 'Destination Location',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                              borderSide: BorderSide.none, // Make the border invisible
                            ),
                            prefixIcon: Icon(
                              Icons.radio_button_checked,
                              color: Colors.deepOrange[100],
                            ),
                          ),
                          onTap: () => _openAutoComplete(context, _endsearchFieldController),
                          onChanged: (value) => _openAutoComplete(context, _endsearchFieldController),
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
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  filled: true,
                                  fillColor: Colors.grey[100],
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
                                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                                    filled: true,
                                    fillColor: Colors.grey[100],
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
            )
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

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  void _openAutoComplete(BuildContext context, TextEditingController controller) async {
    // Show address/place predictions
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: gmaps_api_key,
      mode: Mode.overlay,
      types: [],
      strictbounds: false,
      language: "en",
      components: [Component(Component.country, "us")],
    );
    if(prediction != null){
      PlaceDetails placeDetails = await _getPlaceDetails(prediction.placeId ?? "");
      if (placeDetails != null){
        var location = placeDetails.geometry?.location;
        if (location != null) {
          double latitude = location.lat;
          double longitude = location.lng;
          _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 14.0)
              )
          );
          markers.clear();
          markers.add(
              Marker(markerId: MarkerId('searchLocation'),
                  position: LatLng(latitude, longitude))
          );
        }
        else{
          throw Exception("Location details are null");
        }
      }
      else{
        throw Exception("Failed to fetch place details");
      }
      setState(() {
        controller.text = prediction.description ?? "Not result found";
        FocusScope.of(context).requestFocus(FocusNode());
      });
    }
  }

  Future<PlaceDetails> _getPlaceDetails(String placeId) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: gmaps_api_key);
    PlacesDetailsResponse details = await places.getDetailsByPlaceId(placeId);
    if (details.status == 'OK') {
      return details.result;
    }
    else {
      throw Exception('Failed to retrieve place details');
    }
  }
}
