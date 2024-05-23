import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RideRequestDialog extends StatefulWidget {
  final RemoteMessage remoteMessage;
  final Function(Map<String, dynamic>) onAccept;
  final Function(Map<String, dynamic>) onDecline;

  RideRequestDialog({
    required this.remoteMessage,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  _RideRequestDialogState createState() => _RideRequestDialogState();
}

class _RideRequestDialogState extends State<RideRequestDialog> {
  late Future<Map<String, dynamic>> rideRequestData;

  @override
  void initState() {
    super.initState();
    print('Initializing RideRequestDialog with offeredRideId: ${widget.remoteMessage.data['offeredRideId']} and requestedPassengerId: ${widget.remoteMessage.data['requestedPassengerId']}');
    rideRequestData = fetchRideDetails(widget.remoteMessage.data['offeredRideId'], widget.remoteMessage.data['requestedPassengerId']);
  }

  Future<Map<String, dynamic>> fetchRideDetails(String offeredRideId, String requestedPassengerId) async {
    String baseurl = dotenv.env["BASE_URL"] ?? "";
    String route = 'api/v1/users/getRequestedRide';
    final url = '$baseurl/$route/$offeredRideId/$requestedPassengerId';
    print('Fetching ride details from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Successfully fetched ride details');
      return json.decode(response.body);
    } else {
      print('Failed to load ride details: ${response.statusCode}');
      throw Exception('Failed to load ride details');
    }
  }

  Future<String> getAddressFromLatLong(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(longitude, latitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "";
        if (place.street != null) {
          var split = place.street!.split(" ");
          for(int i=1; i<split.length; i++){
            address += place.street!.split(" ")[i];
            if(i != split.length - 1) address += " ";
          }
        }
        return address;
      } else {
        print("No placemarks found for the given coordinates: Lat=$latitude, Long=$longitude");
        return "No address available";
      }
    } catch (e, stacktrace) {
      print("Failed to get address due to an error: $e");
      print("Stacktrace: $stacktrace");
      return "Failed to get address";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: rideRequestData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            title: Text('Loading...', style: TextStyle(color: Colors.blueAccent)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                SizedBox(height: 10),
                Text('Fetching ride details, please wait...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.blueAccent)),
            content: Text('Failed to load ride details'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return FutureBuilder<List<String>>(
            future: Future.wait([
              getAddressFromLatLong(data['DriverStartLat'], data['DriverStartLng']),
              getAddressFromLatLong(data['DriverEndLat'], data['DriverEndLng']),
              getAddressFromLatLong(data['RiderStartLat'], data['RiderStartLng']),
              getAddressFromLatLong(data['RiderEndLat'], data['RiderEndLng']),
            ]),
            builder: (context, addressSnapshot) {
              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  title: Text('Loading Addresses...', style: TextStyle(color: Colors.blueAccent)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text('Fetching addresses, please wait...'),
                    ],
                  ),
                );
              } else if (addressSnapshot.hasError) {
                return AlertDialog(
                  title: Text('Error', style: TextStyle(color: Colors.blue)),
                  content: Text('Failed to load addresses'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                );
              } else if (addressSnapshot.hasData) {
                final addresses = addressSnapshot.data!;
                return AlertDialog(
                  title: Text('New Ride Request', style : TextStyle(fontWeight: FontWeight.normal, fontFamily: 'DMSans', color: Colors.indigo)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Your Ride'),
                        _buildDetailRow('Start:', addresses[0]),
                        _buildDetailRow('Destination:', addresses[1]),
                        _buildDetailRow('Leaving at:', data['TimeOfJourneyStart']),
                        _buildDetailRow('Available Seats:', data['SeatsAvailable'].toString()),
                        Divider(color: Colors.grey),
                        _buildSectionTitle('Requested Ride'),
                        _buildDetailRow('Passenger :', data['RiderName']),
                        _buildDetailRow('Start:', addresses[2]),
                        _buildDetailRow('Destination:', addresses[3]),
                        _buildDetailRow('Requested Seats:', data['SeatsRequested'].toString()),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.onDecline(widget.remoteMessage.data);
                            Navigator.of(context).pop();
                          },
                          child: Text('Decline', style: TextStyle(fontSize: 18, fontFamily: 'DMSans',color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onAccept(widget.remoteMessage.data);
                            Navigator.of(context).pop();
                          },
                          child: Text('Accept', style: TextStyle(fontSize: 18, fontFamily: 'DMSans', color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, fontFamily: 'DMSans', color: Colors.indigo),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontFamily: 'DMSans')),
          SizedBox(width: 5),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16, fontFamily: 'DMSans'))),
        ],
      ),
    );
  }
}
