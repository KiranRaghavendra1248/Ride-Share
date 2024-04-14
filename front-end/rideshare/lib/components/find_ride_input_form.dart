import 'package:flutter/material.dart';


class InputForm extends StatefulWidget{
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputForm();
}

class _InputForm extends State<InputForm>{
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _seatsController = TextEditingController(text: '1');
  final _startsearchFieldController = TextEditingController();
  final _endsearchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 2,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Column(
              children: [
                TextField(
                  controller: _startsearchFieldController,
                  autofocus: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    labelText: 'Start Location',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      borderSide: BorderSide.none, // Make the border invisible
                    ),
                    prefixIcon: Icon(
                        Icons.radio_button_checked,
                        color: Colors.deepPurple[100]
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _endsearchFieldController,
                  autofocus: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    labelText: 'Destination Location',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      borderSide: BorderSide.none, // Make the border invisible
                    ),
                    prefixIcon: Icon(
                      Icons.radio_button_checked,
                      color: Colors.deepOrange[100],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
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
                    SizedBox(width: 10),
                    Expanded(
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
                        )
                    )
                  ],
                ),
              ],
            ),
          ),
        )
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