import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../components/flutter_polyline_points.dart';
import '../components/network_utililty.dart';
import '../components/src/PointLatLng.dart';
import '../components/src/utils/polyline_result.dart';
import '../components/src/utils/request_enums.dart';
import '../model/polyline_response.dart';

class Ride {
  final int driverId;
  final int rideId;
  final double distanceInMts;
  final String startTime;
  final String startAddress;
  final String destinationAddress;
  final driverDetails;

  Ride(this.driverId, this.rideId, this.distanceInMts, this.startTime, this.startAddress, this.destinationAddress, this.driverDetails);

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      json['DriverID'] as int,
      json['RideID'] as int,
      json['distance_in_meters'].toDouble(),
      json['JourneyStart'] as String,
      "${json['StartAddress']['x']}, ${json['StartAddress']['y']}",
      "${json['DestinationAddress']['x']}, ${json['DestinationAddress']['y']}",
      json['driverDetails']
    );
  }
}

class RequestedRide {
  final int userID;
  final int numSeatsReq;
  final String startAddress;
  final String destinationAddress;
  final String polyline;

  RequestedRide(this.userID, this.numSeatsReq, this.startAddress, this.destinationAddress, this.polyline);
}

class RideDetailPage extends StatefulWidget {
  final Ride ride;
  final RequestedRide requestedRide;

  const RideDetailPage(this.ride, this.requestedRide, Key? key): super(key: key);

  @override
  State<RideDetailPage> createState() => _RideDetailsPage();
}

class _RideDetailsPage extends State<RideDetailPage>{
  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final base_url = dotenv.env["BASE_URL"] ?? "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PolylineResponse polylineResponse = PolylineResponse();
  PolylinePoints polylinePoints = PolylinePoints();

  late GoogleMapController _controller;
  Set<Polyline> polylines_map_input = {};
  Set<Marker> markers = {};

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

  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom: 14.0);

  @override
  Widget build(BuildContext context) {
    Color getColor(double mtsToCover) {
      // This function determines the color from green to red based on the match percentage
      return Color.lerp(Colors.lightGreen, Colors.red[700], mtsToCover / 3000) ?? Colors.lightGreenAccent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Ride Details',
            style : TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.normal,
            )
        ),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('${widget.ride.driverDetails['Name'].toString()}', style: Theme.of(context).textTheme.headline6),
                          Text('${widget.ride.distanceInMts} m to be covered on your own', style: Theme.of(context).textTheme.bodyText1),
                          Text('Starts at: ${widget.ride.startTime}', style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,  // 80% of screen width
                    child: ElevatedButton(
                      onPressed: () async {
                        String route = "api/v1/users/${widget.requestedRide.userID}/requestRide";
                        Map<String, dynamic> requestBody = {
                          'userID': widget.requestedRide.userID,
                          'rideID': widget.ride.rideId,
                          'start': widget.requestedRide.startAddress,
                          'destination': widget.requestedRide.destinationAddress,
                          'polyline': widget.requestedRide.polyline,
                          'numSeats': widget.requestedRide.numSeatsReq
                        };

                        var response = await makePostRequest(base_url, route, requestBody);

                        print("Response from server upon requesting the ride ${response}");

                        showConfirmationDialog(context);
                      },
                      child: Text('Submit Request'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Function to show dialog
  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,  // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Waiting for Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("You'll be notified when the driver accepts the ride request"),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Return to Home Page'),
              onPressed: () {
                // Here we pop the dialog first
                Navigator.of(context).pop();
                // And then navigate to the home page
                Navigator.of(context).popUntil(ModalRoute.withName('/selectMode'));
              },
            ),
          ],
        );
      },
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

  void _addPolyLine(List<LatLng> polylineCoordinates, String color) {
    PolylineId id = PolylineId(color);
    if(color == "Purple"){
      Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.deepPurple,
        width: 4,
      );
      polylines_map_input.add(polyline);
    }
    else{
      Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.blue,
        width: 4,
      );
      polylines_map_input.add(polyline);
    }

  }

  void createPolyline(double _originLatitude, double _originLongitude, double _destLatitude, double _destLongitude, String color) async {
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
    _addPolyLine(polylineCoordinates, color);
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
    LatLng start = parseLatLngFromString(widget.requestedRide.startAddress);
    LatLng destination = parseLatLngFromString(widget.requestedRide.destinationAddress);
    LatLng midPoint = calculateMidpoint(start, destination);

    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint,
                zoom: 10.0)
        )
    );

    var response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key="+gmaps_api_key+
            "&units=metric"+
            "&origin="+widget.requestedRide.startAddress+
            "&destination="+widget.requestedRide.destinationAddress+
            "&mode=driving"
    ));
    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));
    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude, "Purple");

    var secondResponse = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key="+gmaps_api_key+
            "&units=metric"+
            "&origin="+widget.ride.startAddress+
            "&destination="+widget.ride.destinationAddress+
            "&mode=driving"
    ));
    polylineResponse = PolylineResponse.fromJson(jsonDecode(secondResponse.body));
    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude, "Blue");
    setState(() {});
  }
}