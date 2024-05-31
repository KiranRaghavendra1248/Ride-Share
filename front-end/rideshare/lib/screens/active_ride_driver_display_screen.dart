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
    final String route = "api/v1/users/$userID/driverviewPassengers";
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

  /* Added feature to view passengers list */
  void showPassengerDetails(BuildContext context, List<dynamic> passengers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Adjust the border radius here
        ),
        title: Text("Passenger Details", style: TextStyle(fontSize : 22,fontFamily: 'DMSans')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: passengers.map<Widget>((passenger) => ListTile(
            title: Text(passenger['Name'], style: TextStyle(fontSize : 16,fontFamily: 'DMSans', fontWeight: FontWeight.bold)),
            subtitle: Text(passenger['Phone'], style: TextStyle(fontSize : 16,fontFamily: 'DMSans')),
            leading: Icon(Icons.person),
          )).toList(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: TextStyle(fontSize : 16, fontFamily: 'DMSans')),
          ),
        ],
      ),
    );
  }

  /* Integrated firebase messaging to cancel rides */
  void cancelRide(BuildContext context, String rideId) async {
    final base_url = dotenv.env['BASE_URL'] ?? "http://your-api-url.com";
    final userID = BackendIdentifier.userId;
    final String route = "api/v1/users/$userID/$rideId/drivercancel";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Adjust the border radius here
        ),
        title: Text("Confirm Cancellation", style: TextStyle(fontSize : 22, fontFamily: 'DMSans')),
        content: Text("Are you sure you want to cancel this ride?", style: TextStyle(fontSize : 16, fontFamily: 'DMSans')),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop("dummy result");
              Navigator.of(context).pop("dummy result");
              var url = Uri.parse('$base_url/$route');
              Map<String, dynamic> requestBody = {
                'userID': userID.toString(),
                'RideID': rideId,
              };

                var response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: json.encode(requestBody),
                );


              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Ride cancelled successfully', style: TextStyle(fontFamily: 'DMSans')),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to cancel ride', style: TextStyle(fontFamily: 'DMSans')),
                ));
              }
            },
            child: Text("Yes", style: TextStyle(fontSize : 16, fontFamily: 'DMSans', color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Just close the dialog
            },
            child: Text("No", style: TextStyle(fontSize : 16, fontFamily: 'DMSans')),
          ),
        ],
      ),
    );
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
                    Text('Start Address: $startAddress', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                    SizedBox(height: 18),
                    Text('Destination Address: $destinationAddress', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                    SizedBox(height: 18),
                    Text('Starting at $journeyStart', style: TextStyle(fontSize: 18, fontFamily: 'DMSans')),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  try {
                    var passengers = await fetchPassengers(rideId);
                    if (passengers.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Adjust the border radius here
                          ),
                          title: Text("No Passengers", style: TextStyle(fontFamily: 'DMSans')),
                          content: Text("There are no passengers for this ride.", style: TextStyle(fontSize:16, fontFamily: 'DMSans')),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Close", style: TextStyle(fontFamily: 'DMSans')),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showPassengerDetails(context, passengers);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to fetch passengers: $e', style: TextStyle(fontFamily: 'DMSans')),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full width
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue[900]
                ),
                child: Text('View Passengers', style: TextStyle(fontFamily: 'DMSans')),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => cancelRide(context, rideId),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full width
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.red[600]
                ),
                child: Text('Cancel Ride', style: TextStyle(fontFamily: 'DMSans')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
