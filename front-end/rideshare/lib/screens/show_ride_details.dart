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
import '../components/src/utils/polyline_waypoint.dart';
import '../components/src/utils/request_enums.dart';
import '../model/polyline_response.dart';
import 'package:intl/intl.dart';

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
      "${json['StartAddress']['y']}, ${json['StartAddress']['x']}",
      "${json['DestinationAddress']['y']}, ${json['DestinationAddress']['x']}",
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
    DateTime journeyStart = DateTime.parse(widget.ride.startTime);
    String formattedDate = DateFormat('h:mm a on MMM d yyyy').format(journeyStart);
    double distOnOwn = widget.ride.distanceInMts*0.000621371;
    int distanceOnOwn = distOnOwn.toInt();

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
                          Text(
                              'Travel with ${widget.ride.driverDetails['Name'].toString()}',
                              style: TextStyle(fontSize: 18, fontFamily: 'DMSans')
                          ),
                          Text(
                              '${distanceOnOwn} mi to be covered on your own',
                              style: TextStyle(fontSize: 18, fontFamily: 'DMSans')
                          ),
                          Text(
                              'Pickup at: ${formattedDate}',
                            style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
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
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // Adjust the border radius here
                          ),
                          foregroundColor: Colors.white, // Change the background color here
                          backgroundColor: Colors.black38, // Change the text color here
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15)
                      ),
                      child: Text('Submit Request',style: TextStyle(fontSize: 14, fontFamily: 'DMSans'),),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text('Ride Request Submitted',style: TextStyle(fontFamily: 'DMSans'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("You'll be notified when the driver accepts the ride request", style : TextStyle(fontSize: 16, fontFamily: 'DMSans',color: Colors.indigo)),
            ],
          ),
            actions: <Widget>[
              TextButton(
                  child: Text('OK',style : TextStyle(fontSize: 18, fontFamily: 'DMSans',color: Colors.blue)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),]
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

  void _addPolyLine(List<LatLng> polylineCoordinates1, List<LatLng> polylineCoordinates2) {
    Polyline polyline1 = Polyline(
      polylineId: PolylineId("driver"),
      points: polylineCoordinates1,
      color: Colors.deepPurple,
      width: 4,
    );
    Polyline polyline2 = Polyline(
      polylineId: PolylineId("rider"),
      points: polylineCoordinates2,
      color: Colors.deepOrange,
      width: 4,
    );

    LatLng midPoint = calculateMidpoint(polylineCoordinates2[0], polylineCoordinates2[polylineCoordinates2.length-1]);
    _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: midPoint,
                zoom: 14.0)
        )
    );

    polylines_map_input.add(polyline1);
    polylines_map_input.add(polyline2);

    print(polylines_map_input);

    setState(() {});
  }

  void createPolyline(double lat11, double long11, double lat12, double long12, double lat21, double long21, double lat22, double long22) async {
    List<LatLng> polylineCoordinates1 = [];
    List<LatLng> polylineCoordinates2 = [];

    print("Finding route between (${lat11}, ${long11}) and (${lat12}, ${long12})");
    PolylineResult result1 = await polylinePoints.getRouteBetweenCoordinates(
        gmaps_api_key,
        PointLatLng(lat11, long11),
        PointLatLng(lat12, long12),
        travelMode: TravelMode.driving
    );
    if (result1.points.isNotEmpty) {
      result1.points.forEach((PointLatLng point) {
        polylineCoordinates1.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result1.errorMessage);
    }

    print("Finding route between (${lat21}, ${long21}) and (${lat22}, ${long22})");
    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
        gmaps_api_key,
        PointLatLng(lat21, long21),
        PointLatLng(lat22, long22),
        travelMode: TravelMode.driving,
    );
    if (result2.points.isNotEmpty) {
      result2.points.forEach((PointLatLng point) {
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result2.errorMessage);
    }

    _addPolyLine(polylineCoordinates1, polylineCoordinates2);
    setState(() {});
  }

  void drawPolyline() async{
    LatLng passengerstart = parseLatLngFromString(widget.requestedRide.startAddress);
    LatLng passengerdestination = parseLatLngFromString(widget.requestedRide.destinationAddress);

    LatLng driverstart = parseLatLngFromString(widget.ride.startAddress);
    LatLng driverdestination = parseLatLngFromString(widget.ride.destinationAddress);

    print("Creating polylines now for (${driverstart.latitude}, ${driverstart.longitude}) and (${driverdestination.latitude}, ${driverdestination.longitude})");

    createPolyline(passengerstart.latitude, passengerstart.longitude, passengerdestination.latitude, passengerdestination.longitude, driverstart.latitude, driverstart.longitude, driverdestination.latitude, driverdestination.longitude);
    setState(() {});
  }
}