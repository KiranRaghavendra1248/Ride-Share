import 'dart:async';
import 'package:flutter/material.dart';
import 'add_ride_map_screen.dart';

class AddRideFirstScreen extends StatefulWidget {
  const AddRideFirstScreen({super.key});

  @override
  State<AddRideFirstScreen> createState() => _FindRideFirstScreenState();
}

class _FindRideFirstScreenState extends State<AddRideFirstScreen> {
  final _startTimeController = TextEditingController();
  final _dateController = TextEditingController(); // New controller for the date
  final _numSeatsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _dateController.dispose(); // Dispose the new date controller
    _numSeatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
          title: const Text(
              "Ride Share",
              style : TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.normal,
              )
          ),
          backgroundColor: Colors.deepPurple[50],
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
                    const Text(
                      "When are you planning to travel?",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      child: Divider(
                        color: Colors.grey[200],
                        thickness: 4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 300,
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date of travel',
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.deepOrange[100]),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectDate(context);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the date of travel';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: 300,
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: InputDecoration(
                          labelText: 'Start time',
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          prefixIcon: Icon(Icons.schedule, color: Colors.deepOrange[100]),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectTime(context, _startTimeController);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter start time';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: 300,
                      child: TextFormField(
                        controller: _numSeatsController,
                        keyboardType: TextInputType.phone,
                        autofocus: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          labelText: 'Seats available',
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
                            return 'Please enter seats available';
                          }
                          int? intValue = int.tryParse(value);
                          if (intValue == null || intValue < 1 || intValue > 6) {
                            return 'Please enter an number between 1 and 6';
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
                        // Inside the ElevatedButton's onPressed method
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => AddRideMapScreen(
                              date: _dateController.text,
                              startTime: _startTimeController.text,
                              numSeats: int.tryParse(_numSeatsController.text) ?? 1, // Assuming a default value if parsing fails
                            ),
                          ));
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
    );;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
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
