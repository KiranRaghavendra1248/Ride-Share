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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      resizeToAvoidBottomInset : false,
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
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Text(
                      "When are you planning to travel?",
                      style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.bold,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter start time slot';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter end time slot';
                          }
                          return null;
                        },
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
                      child: TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter seats required';
                          }
                          int? intValue = int.tryParse(value);
                          if (intValue == null || intValue < 1 || intValue > 4) {
                            return 'Please enter an number between 1 and 4';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 35),
                    Container(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                            String startTime = _startTimeController.text;
                            String endTime = _endTimeController.text;
                            String numSeats = _numSeatsController.text;
                            return FindRideMapScreen(startTime, endTime, numSeats, null);
                          }));
                        }
                        else{
                          // do noting when form validation fails => stays on same screen
                        }
                      }, child: const Text(
                                        "Next",
                                        style: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: 'DMSans',
                                                  fontWeight: FontWeight.normal,
                                                  ),
                                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6), // Adjust the border radius here
                            ),
                            foregroundColor: Colors.white, // Change the background color here
                            backgroundColor: Colors.black38, // Change the text color here
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
                          ),
                      ),
                    ),
                  ]
              ),
            ),
          )
      ),
    );
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
