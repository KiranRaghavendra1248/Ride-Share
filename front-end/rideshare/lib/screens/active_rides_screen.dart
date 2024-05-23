import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rideshare/screens/active_ride_passenger_display_screen.dart';
import '../ID/backend_identifier.dart'; // Make sure this path is correct.
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/network_utililty.dart';
import 'package:intl/intl.dart';

import 'active_ride_driver_display_screen.dart';
import 'active_ride_passenger_display_screen.dart';

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
    String routePassenger = "api/v1/users/$userID/passengeractiverides";
    List<dynamic> response = await makePostRequest(base_url, routePassenger, requestBody);
    setState(() {
      ridesBooked = response.map((ride) => BookedRide.fromJson(ride)).toList();
    });
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
              var ride = ridesOffered[index];
              double startX = ride.StartAddress['x']; // Longitude
              double startY = ride.StartAddress['y']; // Latitude
              double destX = ride.DestinationAddress['x']; // Longitude
              double destY = ride.DestinationAddress['y']; // Latitude

              return FutureBuilder(
              future: Future.wait([
              getAddressFromLatLong(startX, startY),
              getAddressFromLatLong(destX, destY),
              ]),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                DateTime journeyStart = DateTime.parse(ridesOffered[index].TimeOfJourneyStart);
                String formattedDate = DateFormat('h:mm a on MMM d yyyy').format(journeyStart);
                return ListTile(
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(3, 3, 0, 0),
                  child: Text(
                  "${snapshot.data![0]} - ${snapshot.data![1]}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.bold,
                      )
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 0, 0),
                  child: Text(
                      "Starting Journey at ${formattedDate}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.normal,
                      )
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RideDetailScreen(
                          rideId : ridesOffered[index].RideID,
                          startAddress : snapshot.data![0],
                          destinationAddress : snapshot.data![1],
                          journeyStart: formattedDate)
                      )
                  );
                },
                // Add other ride details here
                );
              }
              }
              );
            },
          ),
          // Rides Booked Tab
      ListView.builder(
        itemCount: ridesBooked.length,
        itemBuilder: (context, index) {
          var ride = ridesBooked[index];
          double startX = ride.StartAddress['x']; // Longitude
          double startY = ride.StartAddress['y']; // Latitude
          double destX = ride.DestinationAddress['x']; // Longitude
          double destY = ride.DestinationAddress['y']; // Latitude

          return FutureBuilder(
              future: Future.wait([
                getAddressFromLatLong(startX, startY),
                getAddressFromLatLong(destX, destY),
              ]),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                else {
                  DateTime journeyStart = DateTime.parse(ridesBooked[index].TimeOfJourneyStart);
                  String formattedDate = DateFormat('h:mm a on MMM d yyyy').format(journeyStart);
                  return ListTile(
                    title: Text(
                        "${snapshot.data![0]} - ${snapshot.data![1]}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.bold,
                        )
                    ),
                    subtitle: Text(
                        "Pickup at ${formattedDate}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.normal,
                        )
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => RideDetailScreenPassenger(
                              bookedRide : ridesBooked[index], StartAddress : snapshot.data![0], DestinationAddress : snapshot.data![1], journeyStart : formattedDate
                          )
                          )
                      );
                    },
                  );
                }
              }
          );
        },
      ),
        ],
      ),
    );
  }
}

class BookedRide {
  final String RideID, DriverRideID, TimeOfJourneyStart;
  final driverDetails, StartAddress, DestinationAddress;
  // Add other fields here

  BookedRide({required this.RideID, required this.StartAddress, required this.DestinationAddress, required this.DriverRideID, required this.TimeOfJourneyStart, required this.driverDetails});

  factory BookedRide.fromJson(Map<String, dynamic> json) {
    return BookedRide(
        RideID : json['RideID'].toString(),
        StartAddress : json['StartAddress'],
        DestinationAddress : json['DestinationAddress'],
        DriverRideID : json['DriverRideID'].toString(),
        TimeOfJourneyStart : json['TimeOfJourneyStart'],
        driverDetails : json['driverDetails']
    );
  }
}

class OfferedRide {
  final String RideID, DriverID, TimeOfJourneyStart, SeatsAvailable;
  final StartAddress, DestinationAddress;
  // Add other fields here
  OfferedRide({required this.RideID, required this.DriverID, required this.StartAddress, required this.DestinationAddress, required this.TimeOfJourneyStart, required this.SeatsAvailable});

  factory OfferedRide.fromJson(Map<String, dynamic> json) {
    return OfferedRide(
        RideID : json['RideID'].toString(),
        DriverID : json['DriverID'].toString(),
        StartAddress : json['StartAddress'],
        DestinationAddress : json['DestinationAddress'],
        TimeOfJourneyStart : json['JourneyStart'],
        SeatsAvailable : json['SeatsAvailable'].toString()
    );
  }
}



