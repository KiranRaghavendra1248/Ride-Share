import 'package:flutter/material.dart';
import 'add_ride_first_screen.dart';
import 'find_ride_first_screen.dart';
import '../theme/theme.dart';

class SelectMode extends StatelessWidget {
  const SelectMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Mode"),
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
              }, child: const Text("Find Ride", style: TextStyle(
                fontSize: 18,
                fontFamily: 'DMSans',
                fontWeight: FontWeight.normal,
              ),
              ),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent, // Change the background color here
                    backgroundColor: Colors.white, // Change the text color here
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
                  )
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                  return const AddRideFirstScreen();
                }));
              }, child: const Text("Submit Ride", style: TextStyle(
                fontSize: 18,
                fontFamily: 'DMSans',
                fontWeight: FontWeight.normal,
              ),
              ),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent, // Change the background color here
                    backgroundColor: Colors.white, // Change the text color here
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
              ),
              )
            )
          ]

        )
      ),
    );
  }
}
