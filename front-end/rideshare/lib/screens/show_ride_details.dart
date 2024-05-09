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

  Ride(this.driverId, this.rideId, this.distanceInMts, this.startTime, this.startAddress, this.destinationAddress);

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      json['DriverID'] as int,
      json['RideID'] as int,
      json['distance_in_meters'].toDouble(),
      json['JourneyStart'] as String,
      "${json['StartAddress']['x']}, ${json['StartAddress']['y']}",
      "${json['DestinationAddress']['x']}, ${json['DestinationAddress']['y']}",
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

class RideDetailPage extends StatelessWidget {
  final Ride ride;
  final RequestedRide requestedRide;

  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final base_url = dotenv.env["BASE_URL"] ?? "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PolylineResponse polylineResponse = PolylineResponse();
  PolylinePoints polylinePoints = PolylinePoints();

  late GoogleMapController _controller;
  Set<Polyline> polylines_map_input = {};
  Set<Marker> markers = {};

  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom: 14.0);

  RideDetailPage({Key? key, required this.ride, required this.requestedRide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getColor(double percentage) {
      // This function determines the color from green to red based on the match percentage
      return Color.lerp(Colors.redAccent, Colors.lightGreenAccent, percentage / 100) ?? Colors.lightGreenAccent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('${ride.driverId}', style: Theme.of(context).textTheme.headline6),
                          Text('${ride.rideId}', style: Theme.of(context).textTheme.bodyText1),
                          Text('Starts at: ${ride.startTime}', style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: getColor(ride.distanceInMts),
                        child: Text('${ride.distanceInMts.toInt()}%'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,  // 80% of screen width
                    child: ElevatedButton(
                      onPressed: () async {
                        String route = "api/v1/users/${requestedRide.userID}/requestRide";
                        Map<String, dynamic> requestBody = {
                          'userID': requestedRide.userID,
                          'rideID': ride.rideId,
                          'start': requestedRide.startAddress,
                          'destination': requestedRide.destinationAddress,
                          'polyline': requestedRide.polyline,
                          'numSeats': requestedRide.numSeatsReq
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

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: Colors.deepPurple,
      width: 4,
    );
    polylines_map_input.add(polyline);
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
    LatLng start = parseLatLngFromString(requestedRide.startAddress);
    LatLng destination = parseLatLngFromString(requestedRide.destinationAddress);
    LatLng midPoint = calculateMidpoint(start, destination);

    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint,
                zoom: 10.0)
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
            "&origin="+requestedRide.startAddress+
            "&destination="+requestedRide.destinationAddress+
            "&mode=driving"
    ));

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude);
    // setState(() {});
  }
}