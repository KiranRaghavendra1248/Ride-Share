import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../ID/backend_identifier.dart';

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

  final gmaps_api_key = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
  final base_url = dotenv.env["BASE_URL"] ?? "";

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
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapPins();
    _setPolylines();
  }

  String _encodePolyline(List <LatLng> points) {
    int prevLat = 0;
    int prevLng = 0;
    StringBuffer encoded = StringBuffer();

    for (LatLng point in points) {
      int lat = (point.latitude * 1E5).round();
      int lng = (point.longitude * 1E5).round();
      int dLat = lat - prevLat;
      int dLng = lng - prevLng;

      _encodeDifference(encoded, dLat);
      _encodeDifference(encoded, dLng);

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  void _encodeDifference(StringBuffer encoded, int diff) {
    int shifted = diff << 1;
    if (diff < 0) {
      shifted = ~shifted;
    }
    int rem = shifted;

    while (rem >= 0x20) {
      encoded.writeCharCode((0x20 | (rem & 0x1f)) + 63);
      rem >>= 5;
    }
    encoded.writeCharCode(rem + 63);
  }

  Future<dynamic> makePostRequest(String baseUrl, String route, Map<String, dynamic> requestBody) async {
    String apiUrl = '$baseUrl/$route';

    try {
      // Make the API call and await the response
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response JSON
        dynamic responseData = json.decode(response.body);
        // Return the parsed response
        return responseData;
      } else {
        // Handle error response
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      return null;
    }
  }

  void _setMapPins() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: widget.destinationLatLng,
        icon: destmarkerIcon// Use the passed LatLng for the destination
      ));
    });
  }

  void _setPolylines() async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.sourceLatLng.latitude},${widget.sourceLatLng.longitude}&'
        'destination=${widget.destinationLatLng.latitude},${widget.destinationLatLng.longitude}&'
         'key= ${gmaps_api_key}';

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
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: widget.sourceLatLng,
              zoom: 8,
            ),
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                          Text("Date of Travel : ${widget.date}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                         fontSize: 20,
                                         fontFamily: 'DMSans',
                                         fontWeight: FontWeight.normal,
                                          )
                          )
                      ]
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start Time: ${widget.startTime}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.normal,
                              )
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
                              child: Text("Source : ${widget.sourceAddress.split(",")[0]}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ) )
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
                              child: Text("Destination : ${widget.destinationAddress.split(",")[0]}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.normal,
                                  ) )
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
                          Text("Seats Available : ${widget.numSeats}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.normal,
                              ) ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () async {
                          int userID = BackendIdentifier.userId;
                          String route = "api/v1/users/$userID/submitrides";
                          Map<String, dynamic> requestBody = {
                            'Date': widget.date,
                            'start_latitude': widget.sourceLatLng.latitude.toString(),
                            'destination_latitude': widget.destinationLatLng.latitude.toString(),
                            'start_longitude': widget.sourceLatLng.longitude.toString(),
                            'destination_longitude': widget.destinationLatLng.longitude.toString(),
                            'startTime': widget.startTime,
                            'numSeats': widget.numSeats.toString(),
                            'polyline': _encodePolyline(_polylines.first.points),
                            'userID': userID.toString()
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
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
