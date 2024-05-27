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
import 'package:rideshare/screens/list_available_rides.dart';
import 'dart:math';

import '../ID/backend_identifier.dart';
import '../components/network_utililty.dart';
import 'show_ride_details.dart';

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
  String polyline = "";
  double travelCost = 0;

  BitmapDescriptor startmarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destmarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/start_location_marker.png")
        .then(
          (icon) {
        setState(() {
          startmarkerIcon = icon;
        });
      },
    );
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/destination_map_marker.png")
        .then(
          (icon) {
        setState(() {
          destmarkerIcon = icon;
        });
      },
    );
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }
  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom: 14.0);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
              "Confirm ride",
              style : TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.normal,
              )),
          elevation: 6,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.deepPurple[50],
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
                  drawPolyline();
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text("Source : ${widget.startLocation.split(",")[0]}",
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
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text("Destination : ${widget.endLocation.split(",")[0]}",
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
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Distance : "+totalDistance,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Duration : "+totalDuration,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cost : "+ travelCost.toString()+" \$",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    int userID = BackendIdentifier.userId;
                                    String route = "api/v1/users/$userID/findrides";
                                    Map<String, dynamic> requestBody = {
                                      'userID': userID.toString(),
                                      'start': widget.startCoordinates.toString(),
                                      'destination': widget.endCoordinates.toString(),
                                      'startTime': widget.startTime,
                                      'endTime': widget.endTime,
                                      'numSeats': widget.numSeats,
                                      'polyline': polyline
                                    };

                                    List<dynamic> rideList = await makePostRequest(base_url, route, requestBody);

                                    print('List of rides: ${rideList}');


                                    // Convert JSON objects to Ride objects
                                    List<Ride> rides = rideList.map((json) => Ride.fromJson(json)).toList();

                                    RequestedRide requestedRide = RequestedRide(userID, int.parse(widget.numSeats.toString()), widget.startCoordinates.toString(), widget.endCoordinates.toString(), polyline);

                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RideListWidget(rides: rides, requestedRide: requestedRide)));
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
      polyline = result.overviewPolyline?? "";
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

  void drawPolyline() async{
    LatLng start = parseLatLngFromString(widget.startCoordinates);
    LatLng destination = parseLatLngFromString(widget.endCoordinates);
    LatLng midPoint = calculateMidpoint(start, destination);

    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint,
                bearing: 10,
                zoom: 14.0)
        )
    );
    markers.clear();
    markers.add(
      Marker(markerId: MarkerId('endLocation'),
          position: destination,
          icon: destmarkerIcon,)
    );

    var response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key="+gmaps_api_key+
            "&units=imperial"+
            "&origin="+widget.startLocation+
            "&destination="+widget.endLocation+
            "&mode=driving"
    ));

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    totalDistance = polylineResponse.routes![0].legs![0].distance!.text!;
    totalDuration = polylineResponse.routes![0].legs![0].duration!.text!;

    travelCost = double.parse(totalDistance.split(" ")[0]);
    travelCost /= 2;

    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude);
    setState(() {});
  }
}
