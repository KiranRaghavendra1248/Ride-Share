import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../ID/backend_identifier.dart';
import '../components/network_utililty.dart';

class PastRidesScreen extends StatefulWidget {
  const PastRidesScreen({Key? key}) : super(key: key);

  @override
  _PastRidesScreenState createState() => _PastRidesScreenState();
}

class _PastRidesScreenState extends State<PastRidesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String base_url = dotenv.env['BASE_URL'] ?? "";
  final int userID = BackendIdentifier.userId;
  List<OfferedRide> ridesOffered = [];
  List<BookedRide> ridesBooked = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDriverRides();
    fetchPassengerRides();
  }

  Future<void> fetchPassengerRides() async {
    // API call to retrieve Offered Rides
    String routePassenger = "api/v1/users/riderRideHistory/$userID";
    List<dynamic> response = await makeGetRequest(base_url, routePassenger);
    if(response[0]["message"] == "No rides available"){
      return;
    }
    setState(() {
      ridesBooked = response.map((ride) => BookedRide.fromJson(ride)).toList();
    });
  }

  Future<void> fetchDriverRides() async {
    // API call to retrieve Booked Rides
    String routeDriver = "api/v1/users/driverRideHistory/$userID";
    List<dynamic> response = await makeGetRequest(base_url, routeDriver);
    if(response[0]["message"] == "No rides available"){
      return;
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Rides Offered'),
            Tab(text: 'Rides Booked'),
          ],
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
                              "Travelled at ${formattedDate}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.normal,
                              )
                          ),
                        ),
                        onTap: () {

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
                            "Travelled at ${formattedDate}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.normal,
                            )
                        ),
                        onTap: () {

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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