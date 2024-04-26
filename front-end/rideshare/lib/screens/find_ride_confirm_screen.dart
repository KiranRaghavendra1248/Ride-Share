import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rideshare/components/flutter_polyline_points.dart';
import 'package:rideshare/components/src/PointLatLng.dart';
import 'package:rideshare/components/src/utils/polyline_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rideshare/components/src/utils/request_enums.dart';
import 'package:rideshare/model/polyline_response.dart';
import 'dart:math';

import '../components/network_utililty.dart';

class ConfirmRideMapScreen extends StatefulWidget {
  final startTime, endTime, numSeats, startLocation, endLocation, startCoordinates, endCoordinates;
  const ConfirmRideMapScreen(this.startTime, this.endTime, this.numSeats, this.startLocation, this.endLocation, this.startCoordinates, this.endCoordinates, Key? key): super(key: key);

  @override
  State<ConfirmRideMapScreen> createState() => _ConfirmRideMapScreen();
}

class _ConfirmRideMapScreen extends State<ConfirmRideMapScreen> {

  late GoogleMapController _controller;
  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final base_url = dotenv.env["BASE_URL"] ?? "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PolylineResponse polylineResponse = PolylineResponse();

  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> polylines_map_input = {};
  String totalDistance = "";
  String totalDuration = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
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
          title: const Text("Confirm ride"),
          elevation: 6,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.lightBlue[200],
        ),
        body: Stack(
          children: [
            GoogleMap(
                polylines: polylines_map_input,
                initialCameraPosition: initialPosition,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
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
                                child: Text("Total Distance : "+totalDistance,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Text("Total Duration : "+totalDuration,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    int userID = 5679;
                                    String route = "api/v1/users/$userID/rides";
                                    Map<String, dynamic> requestBody = {
                                      'userID': '12345',
                                      'start': widget.startCoordinates.toString(),
                                      'destination': widget.endCoordinates.toString(),
                                      'startTime': widget.startTime,
                                      'endTime': widget.endTime,
                                      'numSeats': widget.numSeats
                                    };
                                    var response = await makePostRequest(base_url, route, requestBody);
                                    print(response);
                                  },
                                  child: Text("Confirm", style: TextStyle(
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
                                  )
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

  LatLng parseLatLngFromString(String latLngString) {
    // Split the string by comma
    List<String> parts = latLngString.split(',');

    // Extract latitude and longitude
    double latitude = double.parse(parts[0]);
    double longitude = double.parse(parts[1]);

    return LatLng(latitude, longitude);
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  double degrees(double radians) {
    return radians * 180 / pi;
  }

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: Colors.deepPurple,
      width: 4,
    );
    polylines_map_input.add(polyline);
    setState(() {});
  }

  void createPolyline(double _originLatitude, double _originLongitude, double _destLatitude, double _destLongitude) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gmaps_api_key,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.driving
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }


  LatLng calculateMidpoint(LatLng point1, LatLng point2) {
    // Convert degrees to radians
    final lat1 = radians(point1.latitude);
    final lon1 = radians(point1.longitude);
    final lat2 = radians(point2.latitude);
    final lon2 = radians(point2.longitude);

    // Calculate average latitudes and longitudes
    final avgLat = (lat1 + lat2) / 2;
    final avgLon = (lon1 + lon2) / 2;

    // Convert radians back to degrees
    final avgLatDegrees = degrees(avgLat);
    final avgLonDegrees = degrees(avgLon);

    return LatLng(avgLatDegrees, avgLonDegrees);
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
    drawPolyline(position);
  }

  void drawPolyline(Position position) async{
    LatLng start = parseLatLngFromString(widget.startCoordinates);
    LatLng destination = parseLatLngFromString(widget.endCoordinates);
    LatLng midPoint = calculateMidpoint(start, destination);

    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint,
                zoom: 8.0)
        )
    );
    markers.clear();
    markers.add(
      Marker(markerId: MarkerId('startLocation'),
          position: start),

    );
    markers.add(
      Marker(markerId: MarkerId('endLocation'),
          position: destination),

    );

    var response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key="+gmaps_api_key+
            "&units=metric"+
            "&origin="+widget.startLocation+
            "&destination="+widget.endLocation+
            "&mode=driving"
    ));

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    totalDistance = polylineResponse.routes![0].legs![0].distance!.text!;
    totalDuration = polylineResponse.routes![0].legs![0].duration!.text!;

    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude);
    setState(() {});
  }
}
