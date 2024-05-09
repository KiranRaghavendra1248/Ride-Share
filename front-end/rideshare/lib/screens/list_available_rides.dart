import 'package:flutter/material.dart';

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
              Text(ride.driverId.toString(), style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8),
              Text('Distance to cover: ${ride.distanceInMts}%',
                  style: Theme.of(context).textTheme.subtitle1),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.blue), // Car icon
                  SizedBox(width: 10), // Space between the icon and the text
                  Text(ride.rideId.toString(), style: Theme.of(context).textTheme.bodyText1), // Car name next to the icon
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

  @override
  Widget build(BuildContext context) {
    List<Ride> sortedRides =
    List.from(rides)..sort((a, b) => a.distanceInMts.compareTo(b.distanceInMts));

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rides'),
      ),
      body: ListView.builder(
        itemCount: sortedRides.length,
        itemBuilder: (context, index) {
          return RideWidget(
            ride: sortedRides[index],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetailPage(ride: sortedRides[index], requestedRide: requestedRide))),
          );
        },
      ),
    );
  }
}