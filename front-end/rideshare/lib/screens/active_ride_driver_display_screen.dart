import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../ID/backend_identifier.dart';

class RideDetailScreen extends StatelessWidget {
  final String rideId;
  final String startAddress;
  final String destinationAddress;
  final String journeyStart;

  const RideDetailScreen({
    Key? key,
    required this.rideId,
    required this.startAddress,
    required this.destinationAddress,
    required this.journeyStart,
  }) : super(key: key);

  Future<List<dynamic>> fetchPassengers(String rideId) async {
    final base_url = dotenv.env['BASE_URL'] ?? "http://your-api-url.com";
    final userID = BackendIdentifier.userId;
    final String route = "api/v1/users/$userID/viewPassengers";
    var url = Uri.parse('$base_url/$route');
    Map<String, dynamic> requestBody = {
      'userID': userID.toString(),
      'RideID': rideId,
    };

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      print('Error fetching passengers: $e');
      return [];  // Return empty list on error
    }
  }

  Future<void> cancelRide(String rideId) async {
    var url = Uri.parse('https://yourbackend.example.com/api/v1/rides/$rideId/cancel');
    var response = await http.post(url);
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to cancel ride');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details', style: TextStyle(fontFamily: 'DMSans')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ride ID: $rideId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, fontFamily: 'DMSans')),
                    SizedBox(height: 18),
                    Text('Start : $startAddress', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                    SizedBox(height: 18),
                    Text('Destination : $destinationAddress', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                    SizedBox(height: 18),
                    Text('Starting at $journeyStart', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      var passengers = await fetchPassengers(rideId);
                      if (passengers.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            title: Text("No Passengers", style: TextStyle(fontFamily: 'DMSans')),
                            content: Text("There are no passengers for this ride.", style: TextStyle(fontFamily: 'DMSans')),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Close", style: TextStyle(fontFamily: 'DMSans')),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Logic to show passenger details
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to fetch passengers: $e', style: TextStyle(fontFamily: 'DMSans')),
                      ));
                    }
                  },
                  child: const Text('View Passengers', style: TextStyle(fontFamily: 'DMSans')),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // Adjust the border radius here
                      ),
                      foregroundColor: Colors.white, // Change the background color here
                      backgroundColor: Colors.blue[900], // Change the text color here
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15)
                  )
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Ride cancelled successfully', style: TextStyle(fontFamily: 'DMSans')),
                      ));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to cancel ride: $e', style: TextStyle(fontFamily: 'DMSans')),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // Adjust the border radius here
                      ),
                      foregroundColor: Colors.white, // Change the background color here
                      backgroundColor: Colors.red[600], // Change the text color here
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15)
                  ),
                  child: const Text('Cancel Ride', style: TextStyle(fontFamily: 'DMSans')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}