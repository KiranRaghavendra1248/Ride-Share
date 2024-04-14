import 'package:flutter/material.dart';
import 'package:rideshare/screens/find_ride_home_map_screen.dart';

class SelectMode extends StatefulWidget {
  const SelectMode({super.key});

  @override
  State<SelectMode> createState() => _SelectModeState();
}

class _SelectModeState extends State<SelectMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text("Select Mode"),
        backgroundColor: Colors.lightBlue[200],
        elevation: 6,
        shadowColor: Colors.grey
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return const FindRideHomeMapScreen();
              }));
            }, child: const Text("Find Ride"),),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return const FindRideHomeMapScreen();
              }));
            }, child: const Text("Submit Ride"),)

          ]

        )
      ),
    );
  }
}

