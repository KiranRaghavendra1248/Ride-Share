import 'package:flutter/material.dart';

class Ride {
  final String name;
  final double matchPercentage;
  final String carName;
  final String startTime;

  Ride({
    required this.name,
    required this.matchPercentage,
    required this.carName,
    required this.startTime,
  });
}

class RideDetailPage extends StatelessWidget {
  final Ride ride;

  const RideDetailPage({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getColor(double percentage) {
      // This function determines the color from green to red based on the match percentage
      return Color.lerp(Colors.redAccent, Colors.lightGreenAccent, percentage / 100) ?? Colors.lightGreenAccent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center (
                child: Text("Google maps will be displayed here", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('${ride.name}', style: Theme.of(context).textTheme.headline6),
                        Text('${ride.carName}', style: Theme.of(context).textTheme.bodyText1),
                        Text('Starts at: ${ride.startTime}', style: Theme.of(context).textTheme.bodyText1),
                      ],
                    ),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: getColor(ride.matchPercentage),
                      child: Text('${ride.matchPercentage.toInt()}%'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,  // 80% of screen width
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement submission logic here
                    },
                    child: Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}