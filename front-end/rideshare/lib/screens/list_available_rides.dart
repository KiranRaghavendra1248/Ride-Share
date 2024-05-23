import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import 'show_ride_details.dart';

class RideWidget extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;

  const RideWidget({Key? key, required this.ride, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.driverDetails['Name'].toString(), style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8),
              Text('Distance to cover: ${ride.distanceInMts} meters',
                  style: Theme.of(context).textTheme.subtitle1),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.blue), // Car icon
                  SizedBox(width: 10), // Space between the icon and the text
                  Text(/*ride.rideId.toString()*/ 'Tesla Model 3', style: Theme.of(context).textTheme.bodyText1), // Car name next to the icon
                ],
              ),
              SizedBox(height: 8),
              Text('Starts at: ${ride.startTime}', style: Theme.of(context).textTheme.bodyText1),
            ],
          ),
        ),
      ),
    );
  }
}


class RideListWidget extends StatelessWidget {
  final List<Ride> rides;
  final RequestedRide requestedRide;

  const RideListWidget({Key? key, required this.rides, required this.requestedRide}) : super(key: key);

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
        title: Text(
            'Available Rides',
            style : TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.normal,
            )
        ),
        elevation: 6,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.deepPurple[50],
      ),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          var ride = rides[index];
          double startX = double.parse(ride.startAddress.split(",")[0]); // Longitude
          double startY = double.parse(ride.startAddress.split(",")[1]); // Latitude
          double destX = double.parse(ride.destinationAddress.split(",")[0]); // Longitude
          double destY = double.parse(ride.destinationAddress.split(",")[1]); // Latitude

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
                  DateTime journeyStart = DateTime.parse(rides[index].startTime);
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
                          MaterialPageRoute(builder: (context) =>  RideDetailPage(rides[index], requestedRide, null)));
                    },
                    // Add other ride details here
                  );
                }
              }
          );
        },
      ),
    );
  }
}