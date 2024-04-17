import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

import 'confirm_ride_map_screen.dart';

class FindRideMapScreen extends StatefulWidget {
  final startTime, endTime, numSeats;
  const FindRideMapScreen(this.startTime, this.endTime, this.numSeats, Key? key): super(key: key);

  @override
  State<FindRideMapScreen> createState() => _FindRideMapScreenState();
}

class _FindRideMapScreenState extends State<FindRideMapScreen> {

  late GoogleMapController _controller;
  final _startsearchFieldController = TextEditingController();
  final _endsearchFieldController = TextEditingController();
  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
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
          title: const Text("Find a ride"),
          elevation: 6,
          shadowColor: Colors.transparent,
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
            Form(
              key: _formKey,
              child: Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Text("Where to??",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 250,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Divider(
                                    color: Colors.grey[200],
                                    thickness: 4, // Adjust the thickness as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          TextFormField(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter start location';
                              }
                              return null;
                            },
                            readOnly: true,
                            onTap: () => _openAutoComplete(context, _startsearchFieldController),
                            onChanged: (value) => _openAutoComplete(context, _startsearchFieldController),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter destination';
                              }
                              return null;
                            },
                            readOnly: true,
                            onTap: () => _openAutoComplete(context, _endsearchFieldController),
                            onChanged: (value) => _openAutoComplete(context, _endsearchFieldController),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (){
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                                      String startLocation = _startsearchFieldController.text;
                                      String endLocation = _endsearchFieldController.text;
                                      return ConfirmRideMapScreen(widget.startTime, widget.endTime, widget.numSeats, startLocation, endLocation, null);
                                    }));
                                  }
                                  else{
                                    // do noting when form validation fails => stays on same screen
                                    }
                                  },
                                child: Text("Find a ride", style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.normal,
                                )
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6), // Adjust the border radius here
                                  ),
                                  foregroundColor: Colors.white, // Change the background color here
                                  backgroundColor: Colors.black38, // Change the text color here
                                ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
              ),
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
