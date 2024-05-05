import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../components/flutter_polyline_points.dart';
import '../components/src/PointLatLng.dart';
import '../components/src/utils/polyline_result.dart';
import '../components/src/utils/request_enums.dart';
import '../model/polyline_response.dart';

class Ride {
  final String name;
  final double matchPercentage;
  final String carName;
  final String startTime;

  Ride({
    required this.name,
    required this.matchPercentage,
    required this.carName,
    required this.startTime,
  });
}

class RideDetailPage extends StatelessWidget {
  final Ride ride;
  final String curRideStartCoOrds;
  final String curRideEndCoOrds;
  final String curRideStartLoc;
  final String curRideEndLoc;

  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final base_url = dotenv.env["BASE_URL"] ?? "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PolylineResponse polylineResponse = PolylineResponse();
  PolylinePoints polylinePoints = PolylinePoints();

  late GoogleMapController _controller;
  Set<Polyline> polylines_map_input = {};
  Set<Marker> markers = {};

  static const CameraPosition initialPosition = CameraPosition(target: LatLng(33.684566, -117.826508), zoom: 14.0);

  RideDetailPage({Key? key, required this.ride, required this.curRideStartCoOrds, required this.curRideEndCoOrds, required this.curRideStartLoc, required this.curRideEndLoc}) : super(key: key);

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
                          Text('${ride.name}', style: Theme.of(context).textTheme.headline6),
                          Text('${ride.carName}', style: Theme.of(context).textTheme.bodyText1),
                          Text('Starts at: ${ride.startTime}', style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: getColor(ride.matchPercentage),
                        child: Text('${ride.matchPercentage.toInt()}%'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,  // 80% of screen width
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement submission logic here
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
              Text('Please wait while the driver confirms your ride request.'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();  // Dismiss the dialog
              },
            ),
            ElevatedButton(
              child: Text('Return to Home Page'),
              onPressed: () {
                // Here we pop the dialog first
                Navigator.of(context).pop();
                // And then navigate to the home page
                Navigator.of(context).popUntil((route) => route.isFirst);
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
    LatLng start = parseLatLngFromString(curRideStartCoOrds);
    LatLng destination = parseLatLngFromString(curRideEndCoOrds);
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
            "&origin="+curRideStartLoc+
            "&destination="+curRideEndLoc+
            "&mode=driving"
    ));

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    createPolyline(start.latitude, start.longitude, destination.latitude, destination.longitude);
    // setState(() {});
  }
}