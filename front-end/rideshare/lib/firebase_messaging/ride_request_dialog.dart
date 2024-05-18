import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<String> fetchAddress(double lat, double lng) async {
    String gmapsApiKey = dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "";
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lng,$lat&key=$gmapsApiKey';
    print('Fetching address from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        // Extract the required components
        final components = data['results'][0]['address_components'];
        String street = '';
        String locality = '';
        String administrativeArea = '';
        for (var component in components) {
          if (component['types'].contains('route')) {
            street = component['long_name'];
          }
          if (component['types'].contains('locality')) {
            locality = component['long_name'];
          }
          if (component['types'].contains('administrative_area_level_1')) {
            administrativeArea = component['short_name'];
          }
        }
        String address = '$street, $locality, $administrativeArea';
        print('Successfully fetched address: $address');
        return address;
      } else {
        print('Address not found');
        return 'Address not found';
      }
    } else {
      print('Failed to load address: ${response.statusCode}');
      throw Exception('Failed to load address');
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
              fetchAddress(data['DriverStartLat'], data['DriverStartLng']),
              fetchAddress(data['DriverEndLat'], data['DriverEndLng']),
              fetchAddress(data['RiderStartLat'], data['RiderStartLng']),
              fetchAddress(data['RiderEndLat'], data['RiderEndLng']),
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
                  title: Text('Error', style: TextStyle(color: Colors.blueAccent)),
                  content: Text('Failed to load addresses'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                );
              } else if (addressSnapshot.hasData) {
                final addresses = addressSnapshot.data!;
                return AlertDialog(
                  title: Text('New Ride Request', style: TextStyle(color: Colors.blueAccent)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Your Ride'),
                        _buildDetailRow('Starting from:', addresses[0]),
                        _buildDetailRow('Going to:', addresses[1]),
                        _buildDetailRow('You\'re leaving at:', data['TimeOfJourneyStart']),
                        _buildDetailRow('Available Seats:', data['SeatsAvailable'].toString()),
                        Divider(color: Colors.grey),
                        _buildSectionTitle('Requested Ride'),
                        _buildDetailRow('Passenger Name:', data['RiderName']),
                        _buildDetailRow('Start:', addresses[2]),
                        _buildDetailRow('End:', addresses[3]),
                        _buildDetailRow('Requested Seats:', data['SeatsRequested'].toString()),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.onDecline(widget.remoteMessage.data);
                            Navigator.of(context).pop();
                          },
                          child: Text('Decline', style: TextStyle(color: Colors.blueAccent)),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onAccept(widget.remoteMessage.data);
                            Navigator.of(context).pop();
                          },
                          child: Text('Accept', style: TextStyle(color: Colors.blueAccent)),
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
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
