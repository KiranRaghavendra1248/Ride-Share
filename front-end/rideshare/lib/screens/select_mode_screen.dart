import 'package:flutter/material.dart';
import 'package:rideshare/firebase_messaging/notification_handler.dart';
import 'add_ride_first_screen.dart';
import 'find_ride_first_screen.dart';
import 'active_rides_screen.dart';


class SelectMode extends StatelessWidget {
  const SelectMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Select Mode",
            style : TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.normal,
            )),
      ),
      body: Center( // Wrap Column with Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Text(
              "Hello there!",
              style: TextStyle(
                fontSize: 34,
                fontFamily: 'DMSans',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "How can we help you today?",
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'DMSans',
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                    return const FindRideFirstScreen();
                  }));
                },
                child: const Text(
                  "Find Ride",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                    return const AddRideFirstScreen();
                  }));
                },
                child: const Text(
                  "Submit Ride",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                    return const ActiveRidesScreen();
                  }));
                },
                child: const Text(
                  "Active Rides",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
