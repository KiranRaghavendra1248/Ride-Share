import 'package:flutter/material.dart';
import 'package:rideshare/screens/find_ride_map_screen.dart';

import 'find_ride_first_screen.dart';

class SelectMode extends StatefulWidget {
  const SelectMode({super.key});

  @override
  State<SelectMode> createState() => _SelectModeState();
}

class _SelectModeState extends State<SelectMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar:  AppBar(
        title: const Text("Select Mode"),
        backgroundColor: Colors.lightBlue[200],
        elevation: 6,
        shadowColor: Colors.transparent
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                  return const FindRideFirstScreen();
                }));
              }, child: const Text("Find Ride"),),
            ),
            SizedBox(height: 30),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                  return const FindRideFirstScreen();
                }));
              }, child: const Text("Submit Ride"),),
            )

          ]

        )
      ),
    );
  }
}

