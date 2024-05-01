import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'submit_ride_confirm_screen.dart';

class AddRideMapScreen extends StatefulWidget {
  final String date;
  final String startTime;
  final int numSeats;

  const AddRideMapScreen({super.key,     required this.date,
    required this.startTime,
    required this.numSeats,});

  @override
  State<AddRideMapScreen> createState() => _AddRideMapScreenState();
}

class _AddRideMapScreenState extends State<AddRideMapScreen> {

  late GoogleMapController _controller;
  final _startsearchFieldController = TextEditingController();
  final _endsearchFieldController = TextEditingController();
  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  LatLng? _sourceLatLng;
  LatLng? _destinationLatLng;

  // In _AddRideMapScreenState class
  // In _AddRideMapScreenState class
  void _goToConfirmationScreen(BuildContext context) {
    if (_startsearchFieldController.text.isNotEmpty && _endsearchFieldController.text.isNotEmpty && _sourceLatLng != null && _destinationLatLng != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConfirmRideScreen(
          startTime: widget.startTime,
          date: widget.date,
          sourceAddress: _startsearchFieldController.text,
          destinationAddress: _endsearchFieldController.text,
          numSeats: widget.numSeats,
          sourceLatLng: _sourceLatLng!,  // Use the actual source coordinates
          destinationLatLng: _destinationLatLng!,  // Use the actual destination coordinates
        ),
      ));
    }
  }




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
          title: const Text("Submit a ride"),
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
            Positioned(
                bottom: 2,
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
                              child: Text("I am headed from..",
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
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.radio_button_checked, color: Colors.deepOrange[100]),
                          ),
                          readOnly: true,
                          onTap: () => _openAutoComplete(context, _startsearchFieldController, true),
                        ),
                        SizedBox(height: 15),
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
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.radio_button_checked, color: Colors.deepPurple[100]),
                          ),
                          readOnly: true,
                          onTap: () => _openAutoComplete(context, _endsearchFieldController, false),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 50,
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                              print("Start Text: ${_startsearchFieldController.text}");
                              print("End Text: ${_endsearchFieldController.text}");
                              print("Source LatLng: $_sourceLatLng");
                              print("Destination LatLng: $_destinationLatLng");
                              if (_startsearchFieldController.text.isNotEmpty &&
                                  _endsearchFieldController.text.isNotEmpty &&
                                  _sourceLatLng != null &&
                                  _destinationLatLng != null) {
                                _goToConfirmationScreen(context);
                              }
                            },
                            child: Text("Submit ride", style: TextStyle(
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
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 15)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ),
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

  void _openAutoComplete(BuildContext context, TextEditingController controller, bool isSource) async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: gmaps_api_key,
      mode: Mode.overlay,
      types: [],
      strictbounds: false,
      language: "en",
      components: [Component(Component.country, "us")],
    );
    if (prediction != null) {
      PlaceDetails placeDetails = await _getPlaceDetails(prediction.placeId ?? "");
      if (placeDetails != null) {
        var location = placeDetails.geometry?.location;
        if (location != null) {
          double latitude = location.lat;
          double longitude = location.lng;
          _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                  CameraPosition(target: LatLng(latitude, longitude), zoom: 14.0)
              )
          );
          markers.clear();
          markers.add(
              Marker(markerId: MarkerId('searchLocation'), position: LatLng(latitude, longitude))
          );
          if (isSource) {
            _sourceLatLng = LatLng(latitude, longitude);
          } else {
            _destinationLatLng = LatLng(latitude, longitude);
          }
        } else {
          throw Exception("Location details are null");
        }
      } else {
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