import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ConfirmRideScreen extends StatefulWidget {
  final String startTime;
  final String date;
  final String sourceAddress;
  final String destinationAddress;
  final int numSeats;
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;

  const ConfirmRideScreen({
    Key? key,
    required this.startTime,
    required this.date,
    required this.sourceAddress,
    required this.destinationAddress,
    required this.numSeats,
    required this.sourceLatLng,
    required this.destinationLatLng,
  }) : super(key: key);

  @override
  _ConfirmRideScreenState createState() => _ConfirmRideScreenState();
}

class _ConfirmRideScreenState extends State<ConfirmRideScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapPins();
    _setPolylines();
  }

  void _setMapPins() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: widget.sourceLatLng, // Use the passed LatLng for the source
      ));
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: widget.destinationLatLng, // Use the passed LatLng for the destination
      ));
    });
  }

  void _setPolylines() async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.sourceLatLng.latitude},${widget.sourceLatLng.longitude}&'
        'destination=${widget.destinationLatLng.latitude},${widget.destinationLatLng.longitude}&'
         'key= AIzaSyDN7OVtwKGFU_TTCS7xWkBaGWY0rjyfCFo';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        var steps = data['routes'][0]['legs'][0]['steps'];

        List<LatLng> polylineCoordinates = [];
        for (var step in steps) {
          var polyline = step['polyline']['points'];
          List<LatLng> routePoints = _decodePolyline(polyline);
          polylineCoordinates.addAll(routePoints);
        }

        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            visible: true,
            points: polylineCoordinates,
            width: 4,
            color: Colors.blue,
          ));
        });
      } else {
        print('Directions response was not OK: ${data['status']}');
      }
    } else {
      print('Failed to fetch directions: ${response.statusCode}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Ride Details"),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.sourceLatLng,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Date of Travel: ${widget.date}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Start Time: ${widget.startTime}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Source: ${widget.sourceAddress}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Destination: ${widget.destinationAddress}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Seats Available: ${widget.numSeats}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        // Code to handle submission
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
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
