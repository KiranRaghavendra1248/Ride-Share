import 'dart:async';
import 'package:flutter/material.dart';
import 'find_ride_map_screen.dart';

class FindRideFirstScreen extends StatefulWidget {
  const FindRideFirstScreen({super.key});

  @override
  State<FindRideFirstScreen> createState() => _FindRideFirstScreenState();
}

class _FindRideFirstScreenState extends State<FindRideFirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          title: const Text("Ride Share"),
          backgroundColor: Colors.lightBlue[200],
          elevation: 6,
          shadowColor: Colors.grey
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Container(
                  width: 200,
                  child: ElevatedButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                      return const FindRideMapScreen();
                    }));
                  }, child: const Text("Next"),),
                ),
              ]
          )
      ),
    );;
  }
}
