import 'dart:async';
import 'package:flutter/material.dart';
import 'find_ride_map_screen.dart';

class FindRideFirstScreen extends StatefulWidget {
  const FindRideFirstScreen({super.key});

  @override
  State<FindRideFirstScreen> createState() => _FindRideFirstScreenState();
}

class _FindRideFirstScreenState extends State<FindRideFirstScreen> {
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _numSeatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // Dispose the text field controller when the widget is disposed
    _startTimeController.dispose();
    _endTimeController.dispose();
    _numSeatsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          title: const Text("Ride Share"),
          backgroundColor: Colors.lightBlue[200],
          elevation: 6,
          shadowColor: Colors.transparent
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(
                    "When are you planning to travel?",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    child: Divider(
                      color: Colors.grey[200],
                      thickness: 4, // Adjust the thickness as needed
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width:300,
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                        labelText: 'Start time',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          borderSide: BorderSide.none, // Make the border invisible
                        ),
                        prefixIcon: Icon(
                          Icons.schedule,
                          color: Colors.deepPurple[100],
                        ),
                      ),
                      readOnly: true, // Make the field read-only
                      onTap: () {
                        // Open a date and time picker when the field is tapped
                        _selectTime(context, _startTimeController);
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: 300,
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                        labelText: 'End time',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          borderSide: BorderSide.none, // Make the border invisible
                        ),
                        prefixIcon: Icon(
                          Icons.schedule,
                          color: Colors.deepOrange[100],
                        ),
                      ),
                      readOnly: true, // Make the field read-only
                      onTap: () {
                        // Open a date and time picker when the field is tapped
                        _selectTime(context, _endTimeController);
                      },
                    ),
                  ),
                  SizedBox(height:25),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: _numSeatsController,
                      autofocus: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                        labelText: 'Seats required',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          borderSide: BorderSide.none, // Make the border invisible
                        ),
                        prefixIcon: Icon(
                          Icons.airline_seat_recline_extra,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  Container(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                        return const FindRideMapScreen();
                      }));
                    }, child: const Text("Next"),),
                  ),
                ]
            ),
          )
      ),
    );;
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }
}
