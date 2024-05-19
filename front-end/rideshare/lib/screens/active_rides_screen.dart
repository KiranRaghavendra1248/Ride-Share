import 'package:flutter/material.dart';
import '../ID/backend_identifier.dart'; // Make sure this path is correct.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/network_utililty.dart';
import 'RideListScreen.dart';

class ActiveRidesScreen extends StatefulWidget {
  const ActiveRidesScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRidesScreen> createState() => _ActiveRidesScreen();
}

class _ActiveRidesScreen extends State<ActiveRidesScreen> with SingleTickerProviderStateMixin{
  final String base_url = dotenv.env['BASE_URL'] ?? "";
  final int userID = BackendIdentifier.userId;
  late TabController _tabController;

  List<OfferedRide> ridesOffered = [];
  List<BookedRide> ridesBooked = []; // will get populated on init State via API Call to backend

  Future<void> fetchPassengerRides() async {
    // API call to retrieve Offered Rides
    Map<String, dynamic> requestBody = {
      'userID': userID.toString(),
    };
    // String routePassenger = "api/v1/users/$userID/passengeractiverides";
    // List<dynamic> response = await makePostRequest(base_url, routePassenger, requestBody);
    // setState(() {
    //   ridesBooked = response.map((ride) => BookedRide.fromJson(ride)).toList();;
    // });
  }

  Future<void> fetchDriverRides() async {
    // API call to retrieve Booked Rides
    String routeDriver = "api/v1/users/$userID/driveractiverides";
    Map<String, dynamic> requestBody = {
      'userID': userID.toString(),
    };
    List<dynamic> response = await makePostRequest(base_url, routeDriver, requestBody);
    print("Response from Driver Active Rides");
    print(response);
    setState(() {
      ridesOffered = response.map((ride) => OfferedRide.fromJson(ride)).toList();;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDriverRides();
    fetchPassengerRides();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Rides Offered'),
            Tab(text: 'Rides Booked'),
          ],
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,// Change the color of the highlighted tabs
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Rides Offered Tab
          ListView.builder(
            itemCount: ridesOffered.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    "${ridesOffered[index].StartAddress} to ${ridesOffered[index].DestinationAddress}"
                ),
                subtitle: Text("Starting Journey at ${ridesOffered[index].TimeOfJourneyStart}"),
                // Add other ride details here
              );
            },
          ),
          // Rides Booked Tab
          ListView.builder(
            itemCount: ridesBooked.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  "${ridesBooked[index].StartAddress} to ${ridesBooked[index].DestinationAddress}"
                ),
                subtitle: Text("Pickup at ${ridesBooked[index].TimeOfJourneyStart}"),
                onTap: () {
                  // function to display ride details
                },
                // Add other ride details here
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRideDetails(BuildContext context, String rideTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ride Details'),
          content: Text('Details for the ride: $rideTitle'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class BookedRide {
  final String RideID, StartAddress, DestinationAddress, DriverRideID, TimeOfJourneyStart;
  final driverDetails;
  // Add other fields here

  BookedRide({required this.RideID, required this.StartAddress, required this.DestinationAddress, required this.DriverRideID, required this.TimeOfJourneyStart, required this.driverDetails});

  factory BookedRide.fromJson(Map<String, dynamic> json) {
    return BookedRide(
        RideID : json['RideID'],
        StartAddress : json['StartAddress'],
        DestinationAddress : json['DestinationAddress'],
        DriverRideID : json['DriverRideID'],
        TimeOfJourneyStart : json['TimeOfJourneyStart'],
        driverDetails : json['driverDetails']
    );
  }
}

class OfferedRide {
  final String RideID, DriverID, StartAddress, DestinationAddress, TimeOfJourneyStart, SeatsAvailable;
  // Add other fields here
  OfferedRide({required this.RideID, required this.DriverID, required this.StartAddress, required this.DestinationAddress, required this.TimeOfJourneyStart, required this.SeatsAvailable});

  factory OfferedRide.fromJson(Map<String, dynamic> json) {
    return OfferedRide(
        RideID : json['RideID'],
        DriverID : json['DriverID'],
        StartAddress : json['StartAddress'],
        DestinationAddress : json['DestinationAddress'],
        TimeOfJourneyStart : json['JourneyStart'],
        SeatsAvailable : json['SeatsAvailable']
    );
  }
}



